
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select order_id
from "duckdb-local"."main_staging"."stg_order_line_items"
where order_id is null



  
  
      
    ) dbt_internal_test