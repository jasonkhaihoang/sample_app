
    
    

select
    order_id as unique_field,
    count(*) as n_records

from "duckdb-local"."main_marts"."fct_order_revenue"
where order_id is not null
group by order_id
having count(*) > 1


