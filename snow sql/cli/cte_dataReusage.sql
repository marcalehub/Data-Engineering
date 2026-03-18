WITH CTE(
    SELECT
        order_number,
        order_date,
        amount
    FROM   
        DATABASE.SCHEMA.TABLE_NAME
), CTE2 as (
    SELECT
        row_number() over(partition by  order_number order by order_date desc) entries
    FROM
        CTE
)
SELECT * FROM CTE2