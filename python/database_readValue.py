def odbc ():
    from pyodbc import database_engine
    from pandas import read_sql, DataFrame
    connection = database_engine.connect(f"DSN=DSN; UID=USER; PWD=PASSWORD")
    query = """
        select
            *
        from 
            table
    """
    read = read_sql(query, connection)
    df = DataFrame(read)
    connection.Close()

def oracle ():
    from cx_Oracle import database_engine
    from pandas import read_sql, DataFrame
    connection = database_engine.connect('username', 'password', 'server')
    query = """
        select
            *
        from 
            table
    """
    read = read_sql(query, connection)
    df = DataFrame(read)
    connection.Close()

def sqlalchemy ():
    from sqlalchemy import database_engine
    from pandas import read_sql, DataFrame
    connection = database_engine('oracle://user:password@host:port/database').connect()
    query = """
        select
            *
        from 
            table
    """
    read = read_sql(query, connection)
    df = DataFrame(read)
    connection.Close()

def private_key_load(key = None, location = None):
    password = b'' + key.encode()
    with open(f"{location}\\auth-method\\rsa_key.p8", "rb") as key_file:
        private_key = serialization.load_pem_private_key(
            key_file.read(),
            password=password,
            backend=default_backend()
        )
        pkb = private_key.private_bytes(
            encoding=serialization.Encoding.DER,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        )
    return pkb

def snowflake (location):
    import snowflake.connector as snowflake
    from pandas import read_sql, DataFrame
    connection = snowflake.connect(
        user = 'snowflake_service_account',
        account = 'snowflake_service_account_server',
        database = 'snowflake_service_account_database',
        schema = 'snowflake_service_account_schema',
        warehouse = 'snowflake_service_account_warehouse',
        private_key = private_key_load('snowflake_private_key', location)
    )
    query = """
        select
            *
        from 
            table
    """
    read = read_sql(query, connection)
    df = DataFrame(read)
    connection.Close()