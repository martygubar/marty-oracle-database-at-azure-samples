-- Copyright (c) 2024 Oracle and/or its affiliates.
-- Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

-- Configuration information for Autonomous Database

-- Connect string
-- get the connection string by running ../azure-cli/show-adb-info.sh
-- Example: jdbc:oracle:thin:@(description= ...)
define CONN='your-database-connection-string'  
-- the database user that will own the sample schema
define USER_NAME='moviestream' 
define USER_PASSWORD='your-strong-password' 
--
-- GENAI
--
-- The endpoint should be the servername only. For example, myopenai.openai.azure.com
define AZURE_OPENAI_ENDPOINT='your-azure-openai-endpoint'  
-- Azure OpenAI resource name
define AZURE_OPENAI_RESOURCE_NAME='your-azure-openai-resourcename'
-- Azure OpenAI deployment Name
define AZURE_OPENAI_DEPLOYMENT_NAME='your-azure-openai-deployment-name'
-- Azure OpenAI key
define AZURE_OPENAI_KEY='your-azure-openai-key'

-- Database user that will be connecting to Azure OpenAI plus credential details for connecting to the resource
define AZURE_OPENAI_PROFILE_NAME='gpt4o'
define AZURE_OPENAI_CREDENTIAL_NAME='azure_cred4o'

--
-- Data Lake Storage
--
-- Get this information by running ../azure-cli/show-data-lake-storage-info.sh
define STORAGE_KEY='your-azure-data-lake-storage-key' 
define STORAGE_ACCOUNT_NAME='your-azure-data-lake-storage-account-name'
define STORAGE_URL='https://your-storage-url/adb-sample'