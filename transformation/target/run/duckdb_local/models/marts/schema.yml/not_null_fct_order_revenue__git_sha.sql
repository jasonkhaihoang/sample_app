
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select _git_sha
from "duckdb-local"."main_marts"."fct_order_revenue"
where _git_sha is null



  
  
      
    ) dbt_internal_test