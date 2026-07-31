
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  -- Verify _git_sha contains no whitespace characters.
-- A corrupted value like '\n  local\n' would fail this test while
-- passing plain not_null and non-empty checks.

SELECT *
FROM "duckdb-local"."main_marts"."fct_order_revenue"
WHERE regexp_matches(_git_sha, '\s')
  
  
      
    ) dbt_internal_test