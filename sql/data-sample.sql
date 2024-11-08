-- run the config script to set up variables
@./config.sql

--
-- Use the Oracle LiveLabs workshop utilities to set up a user and add sample data
--
-- install the utilities
prompt Installing workshop utilities
set timing on

declare 
    l_uri varchar2(500) := 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/building_blocks_utilities/o/setup/workshop-setup.sql';
begin
    dbms_cloud_repo.install_sql(
        content => to_clob(dbms_cloud.get_object(object_uri => l_uri))
    );
end;
/

-- add a database user
prompt Adding database user &USER_NAME
exec workshop.add_adb_user('&USER_NAME','&USER_PASSWORD')

-- Run the command below in order to allow the new user (in this case "moviestream") using ORDS.
-- This includes connecting via the ADB SQL Tools
begin 
    ords_admin.enable_schema (
        p_enabled               => TRUE,
        p_schema                => '&USER_NAME',
        p_url_mapping_type      => 'BASE_PATH',
        p_auto_rest_auth        => TRUE   
    );
end;
/
cd
prompt Connecting as database user &USER_NAME
conn &USER_NAME/&USER_PASSWORD@jdbc:oracle:thin:@&CONN

prompt Adding data sets. This will take a few minutes
exec workshop.add_dataset(tag => 'gen-ai')

prompt Done.



