
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select _dbt_invocation_id
from "duckdb-local"."main_marts"."fct_order_revenue"
where _dbt_invocation_id is null



  
  
      
    ) dbt_internal_test