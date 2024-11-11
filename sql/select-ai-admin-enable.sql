-- Copyright (c) 2024 Oracle and/or its affiliates.
-- Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

/* Run this script as the Autonomous Database ADMIN user */
/* You must enable network access to Azure OpenAI for the database user that will be accessing the service */

-- config.sql contains the endpoints, resource groups and other settings required to connect to your Azure OpenAI deployment
@config.sql

BEGIN                                                                          
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(                                      
       host => '&AZURE_OPENAI_ENDPOINT',
       ace  => xs$ace_type(privilege_list => xs$name_list('http'),             
                           principal_name => '&USER_NAME',                          
                           principal_type => xs_acl.ptype_db)                  
 );                                                                            
END;                                                                           
/  