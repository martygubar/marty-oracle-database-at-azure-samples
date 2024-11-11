-- Copyright (c) 2024 Oracle and/or its affiliates.
-- Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

/* Run this script as the Autonomous Database database user that will be access Azure OpenAI */

-- config.sql contains the endpoints, resource groups and other settings required to connect to your Azure OpenAI deployment
@./config.sql

--
-- Customer support site
--
-- Start with the AI profile that uses OCI GenAI llama-3 model + a vector to support RAG
BEGIN  
                                                                           
  DBMS_CLOUD_AI.create_profile(                                                
      'SUPPORT_SITE',                                                                 
      '{"provider": "oci", 
        "credential_name": "OCIAI_CRED",          
        "region":"us-chicago-1",
        "oci_compartment_id":"ocid1.compartment.oc1..aaaaaaaaoroyej3uayfybk6cbgcjkciidbxhcinpxnptcn6ley7bqb677hpq",                                                    
        "vector_index_name": "support"
      }');                                          
end;                                                                           
/ 

-- Create your vector index
begin
       DBMS_CLOUD_AI.create_vector_index(
         index_name  => 'support',
         attributes  => '{"vector_db_provider": "oracle",
                          "location": "https://objectstorage.us-ashburn-1.oraclecloud.com/n/adwc4pm/b/moviestream-support/o/",
                          "profile_name": "SUPPORT_SITE",
                          "vector_dimension": 1024,
                          "vector_distance_metric": "cosine",
                          "chunk_overlap":50,
                          "chunk_size":450
      }');
end;
/

begin
  dbms_cloud_ai.set_profile(
        profile_name => 'SUPPORT_SITE'
    );
end;
/

-- Ask your questions!
SELECT AI NARRATE my roku is stuck on the opening scene of my movie ;

