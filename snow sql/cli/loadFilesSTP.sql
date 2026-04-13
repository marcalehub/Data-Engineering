PUT file:///Path.parquet @$stage;
CREATE OR REPLACE TRANSIENT TABLE DATABASE.SCHEMA.FILE_NAME AS
SELECT 
    $1:access::STRING AS RLS_ACCESS_PAGE,
    $1:users::ARRAY AS RLS_USERS,
    $1:status::STRING AS RLS_STATUS
FROM @$stage/FILE_NAME.parquet (FILE_FORMAT => PARQUET_FORMAT);

CREATE TEMP PROCEDURE STORED_PROCEDURE()
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python', 'pandas')
HANDLER = 'main' as

$$
from snowflake import snowpark
from snowflake.snowpark.functions import flatten, col, regexp_replace
def main(session: snowpark.Session): 
    try:
        df = session.table('DATABASE.SCHEMA.FILE_NAME')
        df = df.join_table_function(flatten(col('RLS_USERS')))
        df = df.select(
            col('RLS_ACCESS_PAGE'),
            col('RLS_STATUS'),
            col('value').alias('RLS_USER')
        )
        df = df.with_column('RLS_USER', regexp_replace(col('RLS_USER'), '^""|""`$', ''))
        df.write.save_as_table(
                    'DATABASE.SCHEMA.TABLE_NAME',  
                    mode='overwrite',
                    table_type='transient'
                )
        return 'Dim View Created Successfully'
    except Exception as e:
        return f'Dim View Was Not Created Successfully: {e}'
$$;

CALL STORED_PROCEDURE();
COPY INTO @$stage/TABLE_NAME.parquet
FROM (
    SELECT
        RLS_ACCESS_PAGE as ""RLS_ACCESS_PAGE"",
        RLS_STATUS as ""RLS_STATUS"",
        RLS_USER as ""RLS_USER""
    FROM DATABASE.SCHEMA.TABLE_NAME
)
FILE_FORMAT = (TYPE = PARQUET)
SINGLE = TRUE;
GET @$stage/TABLE_NAME.parquet file://$fullPath/database/;
DROP TABLE IF EXISTS DATABASE.SCHEMA.TABLE_NAME;