- view: monthly_activity
  derived_table:
    sql_trigger_value: select current_date
    sortkeys: [signup_month]
    distkey: user_id
    sql: |
            SELECT 
                
                users.id as user_id
              , date_trunc ('month', users.created_at) as signup_month
              , month_list.purchase_month as purchase_month
              , COALESCE(data.monthly_purchases, 0) as monthly_purchases
              , COALESCE(data.total_purchase_amount, 0) as monthly_spend
              , row_number() over() AS key
            FROM 
              users
            
            LEFT JOIN 
              
              (
                SELECT 
                  DISTINCT(date_trunc('month', orders.created_at)) as purchase_month
                FROM orders  
              ) as month_list 
            ON month_list.purchase_month >= date_trunc ('month', users.created_at)  -- your dialect will vary
            
            LEFT JOIN 
              
              (
                SELECT 
                      o.user_id
                    , date_trunc('month', o.created_at) as purchase_month
                    , COUNT(distinct o.id) AS monthly_purchases
                    , sum(oi.sale_price) AS total_purchase_amount
                    
                FROM orders o
                LEFT JOIN order_items oi ON o.id = oi.order_id
                GROUP BY 1,2
              ) as data
            ON data.purchase_month = month_list.purchase_month 
            AND data.user_id = users.id


  fields:
  
  - dimension: user_id
    type: number
    sql: ${TABLE}.user_id

  - dimension_group: signup
    type: time
    timeframes: [month]
    sql: ${TABLE}.signup_month

  - dimension_group: purchase
    type: time
    timeframes: [month]
    sql: ${TABLE}.purchase_month
    
  - dimension: months_since_signup
    type: number
    sql: datediff('month', ${TABLE}.signup_month, ${TABLE}.purchase_month)

  - dimension: monthly_purchases
    type: number
    sql: ${TABLE}.monthly_purchases

  - dimension: monthly_spend
    type: number
    sql: ${TABLE}.monthly_spend
    
  - measure: total_users
    type: count_distinct
    sql: ${user_id}

  - measure: total_active_users
    type: count_distinct
    sql: ${user_id}  
    filters:
      monthly_purchases: '>0'

  - measure: percent_of_cohort_active
    type: number
    value_format: '#.#\%'
    sql: 100.0 * ${total_active_users} / nullif(${total_users},0)    

  - measure: total_amount_spent
    type: sum
    value_format: '$#,###'
    sql: ${monthly_spend}
    
  - measure: spend_per_user
    type: number
    value_format: '$#.##'
    sql: ${total_amount_spent} / nullif(${total_users},0)
 
  - measure: spend_per_active_user
    type: number
    value_format: '$#.##'
    sql: ${total_amount_spent} / nullif(${total_active_users},0)    

    
  - dimension: key
    type: int
    primary_key: true
    hidden: true
    sql: ${TABLE}.key

  sets:
    detail:
      - user_id
      - signup_month
      - activity_month
      - monthly_purchases
      - monthly_spend

