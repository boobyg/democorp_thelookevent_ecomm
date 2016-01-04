- view: user_order_facts
  derived_table:
    sql: |
      SELECT
          user_id
        , COUNT(DISTINCT order_id) as lifetime_orders
        , SUM(sale_price) AS lifetime_revenue
        , MIN( NULLIF(created_at,0)) as first_order
        , MAX( NULLIF(created_at,0)) as latest_order
        , COUNT( DISTINCT DATE_TRUNC('month', NULLIF(created_at,0))) as number_of_distinct_months_with_orders
      FROM order_items
      GROUP BY user_id
    sortkeys: [user_id]
    distkey: user_id
    sql_trigger_value: SELECT MAX(id) FROM orders

  fields:
  
  - dimension: user_id
    primary_key: true
    hidden: true
    sql: ${TABLE}.user_id

##### Time and Cohort Fields ######  

  - dimension_group: first_order
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.first_order

  - dimension: latest_order
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.latest_order

  - dimension: days_as_customer
    description: 'Days between first and latest order'
    type: number
    sql: DATEDIFF('day', ${TABLE}.first_order, ${TABLE}.latest_order)+1
    
  - dimension: days_as_customer_tiered
    type: tier
    tiers: [0,1,2,3,4,5,6,7,30,60,90,180]
    sql: ${days_as_customer}

##### Lifetime Behavior - Order Counts ######

  - dimension: lifetime_orders
    type: number
    sql: ${TABLE}.lifetime_orders
  
  - dimension: repeat_customer
    description: 'Lifetime Count of Orders > 1'
    type: yesno
    sql: ${lifetime_orders} > 1
  
  - dimension: lifetime_orders_tier
    type: tier
    tiers: [0,1,2,3,5,10]
    sql: ${lifetime_orders}
    style: integer
    
  - measure: average_lifetime_orders
    type: average
    value_format: '#.##'
    sql: ${lifetime_orders}

  - dimension: distinct_months_with_orders
    type: int
    sql: ${TABLE}.number_of_distinct_months_with_orders

##### Lifetime Behavior - Revenue ######  
  
  - dimension: lifetime_revenue
    type: number
    sql: ${TABLE}.lifetime_revenue
  
  - dimension: lifetime_revenue_tier
    type: tier
    tiers: [0, 25, 50, 100, 200, 500, 1000]
    sql: ${lifetime_revenue}
    style: integer
    
  - measure: average_lifetime_revenue
    type: average
    sql: ${lifetime_revenue}
    

    