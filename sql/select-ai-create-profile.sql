-- Copyright (c) 2024 Oracle and/or its affiliates.
-- Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

/* Create an AI profile that is used by Select AI to connect to your provider. It will also specify the targets used by NL2SQL */

/* Run this script as the Autonomous Database database user that will be access Azure OpenAI */

-- config.sql contains the endpoints, resource groups and other settings required to connect to your Azure OpenAI deployment
@config.sql

 
-- Create a credential that allows the user to access the Azure OpenAI endpoint
DECLARE
    l_exists number := 0;
BEGIN
    -- Create your credential if it does not already exist
    select COUNT(*)
    into l_exists
    from user_credentials    
    where upper(credential_name)=upper('&AZURE_OPENAI_CREDENTIAL_NAME');

    IF l_exists = 0 THEN
        dbms_cloud.create_credential (                                                 
            credential_name => '&AZURE_OPENAI_CREDENTIAL_NAME',                                            
            username => 'AZURE_OPENAI',                                                 
            password => '&AZURE_OPENAI_KEY'
        );
    END IF;                            
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
        profile_name => '&AZURE_OPENAI_PROFILE_NAME',
        force => true
    );

    -- create an AI profile. 
    dbms_cloud_ai.create_profile (
        profile_name => '&AZURE_OPENAI_PROFILE_NAME',
        attributes =>       
            '{"provider": "azure",        
                "azure_resource_name": "&AZURE_OPENAI_RESOURCE_NAME",                    
                "azure_deployment_name": "&AZURE_OPENAI_DEPLOYMENT_NAME",
                "credential_name": "&AZURE_OPENAI_CREDENTIAL_NAME",
                "comments":"true",          
                "object_list": [
                {"owner": "&USER_NAME", "name": "GENRE"},
                {"owner": "&USER_NAME", "name": "CUSTOMER"},
                {"owner": "&USER_NAME", "name": "PIZZA_SHOP"},
                {"owner": "&USER_NAME", "name": "STREAMS"},
                {"owner": "&USER_NAME", "name": "MOVIES"},
                {"owner": "&USER_NAME", "name": "ACTORS"}
                ]          
                }'
    );
    END;
  /
