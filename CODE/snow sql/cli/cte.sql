WITH CTE(
    SELECT
        order_number,
        amount
    FROM   
        DATABASE.SCHEMA.TABLE_NAME
)
SELECT * FROM CTE