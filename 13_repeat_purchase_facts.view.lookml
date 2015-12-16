- view: repeat_purchase_facts
  derived_table:
    sortkeys: [order_id]
    sql_trigger_value: SELECT DATE(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', GETDATE()))
    sql: |
      SELECT
         order_items.order_id 
        ,COUNT(distinct foo.id) AS number_subsequent_orders
        ,MIN(foo.created_at)    AS next_order_date
        ,MIN(foo.order_id)      AS next_order_id
      
      FROM      order_items
      LEFT JOIN order_items foo
      ON        order_items.user_id = foo.user_id
      AND       order_items.created_at < foo.created_at
      GROUP BY  1
      

  fields:

  - dimension: order_id
    type: number
    hidden: true
    primary_key: true
    sql: ${TABLE}.order_id

#### Basic Behavior ####

  - dimension: next_order_id
    type: number
    hidden: true
    sql: ${TABLE}.next_order_id

  - dimension: has_subsequent_order
    type: yesno
    sql: ${next_order_id} > 0

  - dimension: number_subsequent_orders
    type: number
    sql: ${TABLE}.number_subsequent_orders

#### Order Timing ####

  - dimension: next_order
    type: time
    timeframes: [raw, date]
    hidden: true
    sql: ${TABLE}.next_order_date

#   - dimension: days_until_next_order
#     type: number
#     sql: datediff('day',${order_items.created_raw}, ${next_order_raw})
    

#### Repeat Purchase Rate ####
# 
#   - dimension: repeat_orders_within_30d
#     type: yesno
#     sql: ${days_until_next_order} <= 30
#     
#   - measure: count_with_repeat_purchase_within_30d
#     type: count
#     filters:
#       repeat_orders_within_30d: 'Yes'
#       
#   - measure: 30_day_repeat_purchase_rate
#     type: number
#     value_format: '#.##\%'
#     sql: 100.0 * ${count_with_repeat_purchase_within_30d} / nullif(${order_items.order_count},0)
#     drill_fields: [products.brand, orders.count, count_with_repeat_purchase_within_30d]

    



  sets:
    detail:
      - id
      - number_subsequent_orders
      - next_order_date
      - next_order_id