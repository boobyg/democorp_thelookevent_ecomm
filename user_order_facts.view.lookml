- view: user_order_facts
  derived_table:
    sql: |
      SELECT
        orders.user_id as user_id
        , COUNT(*) as lifetime_orders
        , MIN(NULLIF(orders.created_at,0)) as first_order
        , MAX(NULLIF(orders.created_at,0)) as latest_order
        , COUNT(DISTINCT DATE_TRUNC('month', NULLIF(orders.created_at,0))) as number_of_distinct_months_with_orders
      FROM thelook.orders
      GROUP BY user_id
    sortkeys: [user_id]
    distkey: user_id
    sql_trigger_value: SELECT MAX(id) FROM orders

  fields:
  - dimension: user_id
    primary_key: true
    hidden: true
    sql: ${TABLE}.user_id
  
  - dimension: lifetime_orders
    type: number
    sql: ${TABLE}.lifetime_orders

  - dimension: lifetime_orders_tier
    type: tier
    tiers: [0,1,2,3,5,10]
    sql: ${lifetime_orders}
    style: integer
    
  - dimension: repeat_customer
    description: 'Lifetime Count of Orders > 1'
    type: yesno
    sql: ${lifetime_orders} > 1
  
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

  - dimension: distinct_months_with_orders
    type: int
    sql: ${TABLE}.number_of_distinct_months_with_orders
    