/* Run this script as the Autonomous Database database user that will be access Azure OpenAI */

-- config.sql contains the endpoints, resource groups and other settings required to connect to your Azure OpenAI deployment
@./config.sql

-- Create a credential that allows the user to access the Azure OpenAI endpoint
BEGIN                                                                          
    dbms_cloud.create_credential (                                                 
        credential_name => '&azureOpenAICredentialName',                                            
        username => 'AZURE_OPENAI',                                                 
        password => '&azureOpenAIKey'
    );                            
END;                                                                           
/  

/*
  A Select AI profile describes the LLM you will use plus information that will be used for natural language queries. You can create as many 
  AI profiles as you need. You may want to try different models to see their effectiveness, expose profiles to different user groups, etc.:
  1. For Azure OpenAI, a deployment was created that is using the gpt-4o model
  2. The object list contains the tables that will be the targets for natural language queries
*/

BEGIN
    -- recreate the profile
    dbms_cloud_ai.drop_profile (
        profile_name => '&profileName',
        force => true
    );

    -- create an AI profile. 
    dbms_cloud_ai.create_profile (
        profile_name => '&profileName',
        attributes =>       
            '{"provider": "azure",        
                "azure_resource_name": "&azureOpenAIResourceName",                    
                "azure_deployment_name": "&azureOpenAIDeploymentName",
                "credential_name": "&azureOpenAICredentialName",
                "comments":"true",          
                "object_list": [
                {"owner": "&userName", "name": "GENRE"},
                {"owner": "&userName", "name": "CUSTOMER"},
                {"owner": "&userName", "name": "PIZZA_SHOP"},
                {"owner": "&userName", "name": "STREAMS"},
                {"owner": "&userName", "name": "MOVIES"},
                {"owner": "&userName", "name": "ACTORS"}
                ]          
                }'
    );
    END;
  /


-- Set that profile for this session
BEGIN
  dbms_cloud_ai.set_profile(
        profile_name => '&profileName'
    );
END;
/

/**
Start asking questions!
Notice how the SQL language has been extended with new AI keywords
-- 1. chat    - general AI chat
-- 2. runsql  - [default] ask a question and get a structured result
-- 3. narrate - ask a question and get a conversational result
-- 4. showsql - SQL used to produce the result
-- 5. explainsql - explains the query and its processing
*/

-- simple chat
select ai chat what happened to the new england patriots;

-- use your data
select ai what are our total views;
select ai showsql what are our total views;

-- more sophisticated
select ai what are our total streams broken out by genre;
select ai explainsql what are our total streams broken out by genre;

select ai what are total streams by movie for tom hanks movies;

/**
There are also api's for using Select AI
*/
-- Ask another simple question
SELECT 
    DBMS_CLOUD_AI.GENERATE(
        PROMPT => 'What is Tom Hanks best known for',
        PROFILE_NAME => '&profileName',
        ACTION       => 'chat'                     
    ) AS response
FROM dual; 

/**
 what's great is you can now easily apply AI to your organization's data with a simple query
*/
-- look at a humorous support chat
SELECT support_chat 
FROM v_customer_support
WHERE support_chat_id = 1;

/*
Let's summarize find out the sentiment of the support conversation. 
A JSON document is a really good way to structure the prompt; the LLM can easily interpret the 
task and data set to operate on. The following SQL query combines the task with the data set.
*/
-- Here's the task and we'll apply it to the support chat. 
SELECT JSON_OBJECT(
        'task' VALUE 'summarize the support chat in 3 sentences. also return the customer sentiment',
        support_chat) AS prompt_details
FROM v_customer_support WHERE support_chat_id = 1;

-- now apply GenAI in a query to get teh answer
WITH prompt_document AS (
    -- this json document
    SELECT JSON_OBJECT(
        'task' VALUE 'summarize the support chat in 3 sentences. also return the customer sentiment',
        support_chat) AS prompt_details
    FROM v_customer_support WHERE support_chat_id = 1
)
SELECT 
    DBMS_CLOUD_AI.GENERATE(
        PROMPT => prompt_details,
        PROFILE_NAME => '&profileName',
        ACTION       => 'chat'                     
    ) AS response
FROM prompt_document;       

/* Create an EMAIL promotion to a customer. Recommend movies based on
   those they previously watched AND movies that Moviestream wants to promote. 
   This is information the LLM knows nothing about - the prompt will augment the model
   with customer data
*/
WITH promoted_movie_list AS
(
    -- movies we want to promote
    SELECT
        json_arrayagg(json_object(
                'title' value m.json_document.title , 
                'year' value m.json_document.year)
            ) as promoted_movie_list
    FROM "movieCollection" m
    WHERE m.json_document.studio like '%Amblin Entertainment%'
),
customer_latest_movies AS (
    -- movies the customer watched
    SELECT 
        s.cust_id,            
        m.title,
        m.year,
        max(s.day_id) as day_id
    FROM streams s, movies m, v_target_customers c
    WHERE m.movie_id = s.movie_id
        and c.customer_id = 1
        and c.cust_id = s.cust_id
    GROUP BY s.cust_id, m.title, m.year
    ORDER BY day_id desc
    FETCH first 3 ROWS ONLY
),
customer_details AS (
    -- attributes about the customer
    SELECT 
        m.cust_id,
        c.customer_id,
        c.first_name,
        c.last_name,
        c.age,
        c.gender,
        c.has_kids,
        c.marital_status,
        c.dog_owner,
        max(day_id),            
        json_arrayagg(m.title) as recently_watched_movies
    FROM v_target_customers c, customer_latest_movies m
    WHERE 
        c.cust_id = m.cust_id
    GROUP BY  
        m.cust_id,
        c.customer_id,
        first_name,
        last_name,
        age,
        gender,
        has_kids,
        marital_status,
        dog_owner
),
dataset AS (
    -- combine this into a json document
    SELECT json_object(p.*, c.*) doc
    FROM customer_details c, promoted_movie_list p
)
SELECT
    -- generate the promotion!
    DBMS_CLOUD_AI.GENERATE (
        prompt => 'Create a promotional email with a catchy subject line and convincing email text. Follow the task rules. ' ||
                  '1. Recommend 3 movies from the promoted movie list that are most similar to movies in the recently watched movie list. ' ||
                  '   Do not say that we are promoting these movies. For each move, say why you will love them.' || 
                  '2. Use lots of fun emojis in the response. ' ||
                  '3. Finish the email thanking them for being a customer and sign it "From The MovieStream Team" \n' 
                  || doc,
        profile_name => '&profileName',
        action => 'chat'
    ) AS email_promotion
FROM dataset;



