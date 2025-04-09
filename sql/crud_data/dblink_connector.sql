CREATE OR REPLACE FUNCTION connect_to_pg(db_data jsonb)
RETURNS BOOLEAN AS $$
DECLARE
    conn text := db_data->>'conn';
    host text := db_data->>'host';
    port text := db_data->>'port';
    dbname text := db_data->>'dbname';
    user text := db_data->>'user';
    password text := db_data->>'password';
    conn_str text;
BEGIN
    conn_str := format(
        'host=%s port=%s dbname=%s user=%s password=%s',
        host, port, dbname, user, password
    );

    raise notice 'Connecting to %', conn_str;

 -- Try disconnecting first if already connected
    BEGIN
        PERFORM dblink_disconnect(conn);
    EXCEPTION
        WHEN others THEN
            -- ignore errors if not connected
            NULL;
    END;

    PERFORM dblink_connect(conn, conn_str);
    return true;

EXCEPTION
  WHEN others THEN
    RAISE NOTICE 'Connection error: %', SQLERRM;
    return false;
END;
$$ LANGUAGE plpgsql;



select connect_to_pg($$
{
  "conn": "pg1_conn",
  "host": "192.168.0.215",
  "port": "5433",
  "dbname": "aggamedb",
  "user": "aggame_dev",
  "password": "L:>(6]nkYw8se&)UQ{"
}
$$);



select connect_to_pg($$
{
  "conn": "pg2_conn",
  "host": "192.168.0.215",
  "port": "5434",
  "dbname": "aggamedb",
  "user": "aggame_dev",
  "password": "L:>(6]nkYw8se&)UQ{"
}
$$);


select connect_to_pg($$
{
  "conn": "pg3_conn",
  "host": "192.168.0.215",
  "port": "5435",
  "dbname": "aggamedb",
  "user": "aggame_dev",
  "password": "L:>(6]nkYw8se&)UQ{"
}
$$);


select connect_to_pg($$
{
  "conn": "pg4_conn",
  "host": "192.168.0.215",
  "port": "5436",
  "dbname": "aggamedb",
  "user": "aggame_dev",
  "password": "L:>(6]nkYw8se&)UQ{"
}
$$);





CREATE OR REPLACE FUNCTION get_data_as_jsonb_dblink(passing_data jsonb)
RETURNS jsonb AS $$
DECLARE
    result jsonb;

    database_conn jsonb := passing_data ->> 'database_conn';
    conn_name text := database_conn ->> 'conn';

    user_id varchar := passing_data ->> 'user_id';
    conn boolean;
    query text;

BEGIN
    -- Connect to the source database
    conn := (select connect_to_pg(database_conn));

    if conn is false then
        RAISE NOTICE 'Connection failed';
        RETURN '[]'::jsonb; -- Return an empty JSON array in case of connection failure
    end if;

--     query:= format('SELECT row_to_json(t) FROM (SELECT user_fullname, user_email, user_primary_pic FROM auth_user_app_user WHERE userid = %L) t', user_id);
    query:= format('SELECT user_fullname, user_email, user_primary_pic FROM auth_user_app_user WHERE userid = %L', user_id);

    -- Execute query remotely using dblink
        SELECT row_to_json(row) INTO result
            FROM dblink(conn_name, query)
                 AS row(user_fullname jsonb, user_email varchar, user_primary_pic varchar);

--     EXECUTE query INTO result;

    -- Return the result as jsonb
    RETURN result;

EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Error fetching data: %', SQLERRM;
        RETURN '[]'::jsonb; -- Return an empty JSON array in case of error
END;
$$ LANGUAGE plpgsql;


explain analyse select get_data_as_jsonb_dblink($$
    {
    "database_conn" : {
          "conn": "pg4_conn",
          "host": "192.168.0.215",
          "port": "5436",
          "dbname": "aggamedb",
          "user": "aggame_dev",
          "password": "L:>(6]nkYw8se&)UQ{"
        },
    "user_id": "BD__0126103817299479"

    }
$$);

explain analyze SELECT row_to_json(t) FROM (SELECT user_fullname, user_email, user_primary_pic FROM auth_user_app_user WHERE userid = 'BD__0126103817299479') t;


select user_fullname, user_email, user_primary_pic from auth_user_app_user where userid = 'BD__0126103817299479';








--    --   write operation ----------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION update_data_as_jsonb_dblink(passing_data jsonb)
RETURNS jsonb AS $$
DECLARE

    database_conn jsonb := passing_data ->> 'database_conn';
    conn_name text := database_conn ->> 'conn';
    user_id varchar := passing_data ->> 'user_id';
    conn boolean;

    user_fullname jsonb := passing_data ->> 'user_fullname';
    user_email varchar := passing_data ->> 'user_email';
    user_primary_pic varchar := passing_data ->> 'user_primary_pic';
    query text;

BEGIN
    -- Connect to the source database
    conn := (select connect_to_pg(database_conn));

    if conn is false then
        RAISE NOTICE 'Connection failed';
        RETURN '[]'::jsonb; -- Return an empty JSON array in case of connection failure
    end if;

    query:= format('UPDATE auth_user_app_user set user_fullname=%L,user_email=%L,user_primary_pic=%L  WHERE userid = %L',user_fullname,user_email,user_primary_pic, user_id);

    raise notice 'Query:::::::::::::: %', query;

    PERFORM dblink_exec(conn_name, query);

    -- Return the result as jsonb
    RETURN jsonb_build_object('STATUS', 'SUCCESS');

EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Error fetching data: %', SQLERRM;
        RETURN jsonb_build_object('STATUS', 'FAIL');
END;
$$ LANGUAGE plpgsql;




explain analyse select update_data_as_jsonb_dblink($$
    {
    "database_conn" : {
          "conn": "pg4_conn",
          "host": "192.168.0.215",
          "port": "5436",
          "dbname": "aggamedb",
          "user": "aggame_dev",
          "password": "L:>(6]nkYw8se&)UQ{"
        },
    "user_id": "BD__0126103817299479",

    "user_fullname" : {"last_name": "change dblink ", "first_name": "Player1"},
    "user_email" : "player1@ag.com",
    "user_primary_pic" : "baal baal black ship"

    }
$$);


EXPLAIN ANALYSE
UPDATE auth_user_app_user set user_fullname='{"last_name": "change dblink ", "first_name": "Player1"}',user_email='player1@ag.com',user_primary_pic='baal baal black ship'  WHERE userid = 'BD__0126103817299479';


select user_fullname, user_email, user_primary_pic from auth_user_app_user where userid = 'BD__0126103817299479';



