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





CREATE OR REPLACE FUNCTION get_data_as_jsonb(passing_data jsonb)
RETURNS jsonb AS $$
DECLARE
    result jsonb;

    database_conn jsonb := passing_data ->> 'database_conn';
    user_id varchar := passing_data ->> 'user_id';
    conn boolean;

BEGIN
    -- Connect to the source database
    conn := (select connect_to_pg(database_conn));

    if conn is false then
        RAISE NOTICE 'Connection failed';
        RETURN '[]'::jsonb; -- Return an empty JSON array in case of connection failure
    end if;

    EXECUTE 'SELECT row_to_json(t) FROM (SELECT user_fullname, user_email, user_primary_pic FROM auth_user_app_user WHERE userid = '''|| user_id ||''') t'
    INTO result
    USING user_id;

    -- Return the result as jsonb
    RETURN result;

EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Error fetching data: %', SQLERRM;
        RETURN '[]'::jsonb; -- Return an empty JSON array in case of error
END;
$$ LANGUAGE plpgsql;


explain analyse select get_data_as_jsonb($$
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


select * from auth_user_app_user where userid = 'BD__0126103817299479';
