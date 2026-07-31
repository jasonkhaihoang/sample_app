
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select line_item_count
from "duckdb-local"."main_marts"."fct_order_revenue"
where line_item_count is null



  
  
      
    ) dbt_internal_test