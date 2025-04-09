
-- Drop the user mapping for the current user if it exists
DROP USER MAPPING IF EXISTS FOR current_user SERVER pg4_server;

-- Drop the foreign server if it exists
DROP SERVER IF EXISTS pg1_server CASCADE;

-- Creating the foreign server for pg1
CREATE SERVER pg4_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host '192.168.0.215', port '5436', dbname 'aggamedb');

-- Creating the user mapping for pg1
CREATE USER MAPPING FOR current_user
SERVER pg4_server
OPTIONS (user 'aggame_dev', password 'L:>(6]nkYw8se&)UQ{');




-- Create foreign table for auth_user_app_user on pg1
CREATE FOREIGN TABLE auth_user_app_user_pg1 (
    userid varchar,
    user_fullname varchar,
    user_email varchar,
    user_primary_pic bytea
)
SERVER pg4_server
OPTIONS (schema_name 'public', table_name 'auth_user_app_user');






CREATE OR REPLACE FUNCTION get_data_as_jsonb(passing_data jsonb)
RETURNS jsonb AS $$
DECLARE
    result jsonb;
    database_conn jsonb := passing_data ->> 'database_conn';
    user_id varchar := passing_data ->> 'user_id';
BEGIN
    -- Query the foreign table directly
    EXECUTE 'SELECT row_to_json(t) FROM (SELECT user_fullname, user_email, user_primary_pic FROM auth_user_app_user_pg1 WHERE userid = ''' || user_id || ''') t'
    INTO result;

    -- Return the result as jsonb
    RETURN result;

EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Error fetching data: %', SQLERRM;
        RETURN '[]'::jsonb; -- Return an empty JSON array in case of error
END;
$$ LANGUAGE plpgsql;



EXPLAIN ANALYZE
select get_data_as_jsonb($${"user_id" : "BD__0126103817299479"}$$);


EXPLAIN ANALYZE
SELECT row_to_json(t)
FROM (
    SELECT user_fullname, user_email, user_primary_pic
    FROM auth_user_app_user_pg1
    WHERE userid = 'BD__0126103817299479'
) t;
