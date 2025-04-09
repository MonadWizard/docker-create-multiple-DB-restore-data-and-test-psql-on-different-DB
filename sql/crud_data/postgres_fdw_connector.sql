
-- Drop the user mapping for the current user if it exists
DROP USER MAPPING IF EXISTS FOR current_user SERVER pg4_server;

-- Drop the foreign server if it exists
DROP SERVER IF EXISTS pg4_server CASCADE;

-- Creating the foreign server for pg1
CREATE SERVER pg4_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host '192.168.0.215', port '5436', dbname 'aggamedb');

-- Creating the user mapping for pg1
CREATE USER MAPPING FOR current_user
SERVER pg4_server
OPTIONS (user 'aggame_dev', password 'L:>(6]nkYw8se&)UQ{');



drop foreign table if exists auth_user_app_user_pg1;

-- Create foreign table for auth_user_app_user on pg1
CREATE FOREIGN TABLE auth_user_app_user_pg1 (
    userid varchar,
    user_fullname jsonb,
    user_email varchar,
    user_primary_pic varchar
)
SERVER pg4_server
OPTIONS (schema_name 'public', table_name 'auth_user_app_user');





--    read operation ----------------------------------------------------------------------------------------------------------------


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
    FROM auth_user_app_user
    WHERE userid = 'BD__0126103817299479'
) t;







--  --    write operation ----------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_data_as_jsonb(passing_data jsonb)
RETURNS jsonb AS $$
DECLARE
    user_fullname jsonb := passing_data ->> 'user_fullname';
    user_email varchar := passing_data ->> 'user_email';
    user_primary_pic varchar := passing_data ->> 'user_primary_pic';
    user_id varchar := passing_data ->> 'user_id';
    query text;

BEGIN
    -- Query the foreign table directly
    query:= format('UPDATE auth_user_app_user_pg1 set user_fullname=%L,user_email=%L,user_primary_pic=%L  WHERE userid = %L',user_fullname,user_email,user_primary_pic, user_id);

    raise notice 'Query:::::::::::::: %', query;

    EXECUTE query;

    -- Return the result as jsonb
    RETURN jsonb_build_object('STATUS', 'SUCCESS');


EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Error fetching data: %', SQLERRM;
        RETURN jsonb_build_object('STATUS', 'FAIL');
END;
$$ LANGUAGE plpgsql;



EXPLAIN ANALYZE
select update_data_as_jsonb($${
    "user_fullname" : {"last_name": "change fdw pg4", "first_name": "Player1"},
    "user_email" : "player1@ag.com",
  "user_primary_pic" : "baal baal black ship",
    "user_id" : "BD__0126103817299479"
}$$);


EXPLAIN ANALYZE UPDATE auth_user_app_user set user_fullname='{"last_name": "change gc", "first_name": "Player1"}',user_email='player1@ag.com',user_primary_pic='baal baal black ship'  WHERE userid = 'BD__0126103817299479';



select user_fullname from auth_user_app_user where userid = 'BD__0126103817299479';

