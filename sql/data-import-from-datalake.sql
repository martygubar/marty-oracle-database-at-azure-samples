
-- Copyright (c) 2024 Oracle and/or its affiliates.
-- Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

/** Import data to Azure Data Lake **/
@config.sql

-- Create a credential in order to connect to data lake storage
BEGIN
    DBMS_CLOUD.CREATE_CREDENTIAL(
        credential_name => 'ADLS_CRED',
        username => '&STORAGE_ACCOUNT_NAME',
        password => '&STORAGE_KEY'
    );
END;
/

-- List the files
SELECT object_name, bytes 
FROM dbms_cloud.list_objects(
    credential_name => 'ADLS_CRED',
    location_uri => '&STORAGE_URL'
);

-- Create a table for movies that were created from books
drop table movie_from_book;
CREATE TABLE movie_from_book
   (
     movie_name           VARCHAR2(4000)
    ,movie_release_date   DATE
    ,book_name            VARCHAR2(4000)
    ,book_published_date  DATE
    ,description          VARCHAR2(4000)
   );

-- Import data into that new table
BEGIN
  DBMS_CLOUD.COPY_DATA
  ( table_name        => 'MOVIE_FROM_BOOK',
    credential_name   => 'ADLS_CRED',
    file_uri_list     => 'https://storagemartygubaradb.blob.core.windows.net/adb-sample/data/movie_from_book/*.csv',
    field_list        => 'MOVIE_NAME           CHAR(4000),
                          MOVIE_RELEASE_DATE   CHAR date_format DATE MASK "YYYY-MM-DD",
                          BOOK_NAME            CHAR(4000),
                          BOOK_PUBLISHED_DATE  CHAR date_format DATE MASK "YYYY-MM-DD",
                          DESCRIPTION          CHAR(4000)',
    format            => '{
                            "delimiter" : ",",
                            "ignoremissingcolumns" : true,
                            "ignoreblanklines" : true,
                            "blankasnull" : true,
                            "trimspaces" : "lrtrim",
                            "quote" : "\"",
                            "characterset" : "AL32UTF8",
                            "skipheaders" : 1,
                            "logprefix" : "MOVIE_FROM_BOOK",
                            "logretention" : 7,
                            "rejectlimit" : 10000000,
                            "recorddelimiter" : "X''0A''"
                            }'
  );
END;
/

-- Review the results
SELECT * 
FROM movie_from_book;