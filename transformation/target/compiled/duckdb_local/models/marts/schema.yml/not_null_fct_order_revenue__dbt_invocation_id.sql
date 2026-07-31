
    
    



select _dbt_invocation_id
from "duckdb-local"."main_marts"."fct_order_revenue"
where _dbt_invocation_id is null


