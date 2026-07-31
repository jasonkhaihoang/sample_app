
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select _loaded_at
from "duckdb-local"."main_marts"."fct_order_revenue"
where _loaded_at is null



  
  
      
    ) dbt_internal_test