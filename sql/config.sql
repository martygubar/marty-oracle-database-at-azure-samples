-- Configuration information for Autonomous Database

-- Connect string
define CONN='(description= (retry_count=20)(retry_delay=3)(address=(protocol=tcps)(port=1522)(host=adb.us-ashburn-1.oraclecloud.com))(connect_data=(service_name=mqssyowmqvgac1y_azuretest_low.adb.oraclecloud.com))(security=(ssl_server_dn_match=yes)))'
define USER_NAME='moviestream'
define USER_PASSWORD='watchS0meMovies#'
--
-- GENAI
--
-- The endpoint should be the servername only. For example, myopenai.openai.azure.com
define AZURE_OPENAI_ENDPOINT='your-endpoint.openai.azure.com'
-- Azure OpenAI resource name
define AZURE_OPENAI_RESOURCE_NAME='your-resource-name'
-- Azure OpenAI deployment Name
define AZURE_OPENAI_DEPLOYMENT_NAME='your-deployment-name'
-- Azure OpenAI key
define AZURE_OPENAI_KEY='your-azure-openai-key'

-- Database user that will be connecting to Azure OpenAI plus credential details for connecting to the resource
define AZURE_OPENAI_PROFILE_NAME='gpt4o'
define AZURE_OPENAI_CREDENTIAL_NAME='azure_cred4o'
