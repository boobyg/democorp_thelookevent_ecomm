- view: subsequent_order_facts
  derived_table:
    sortkeys: [id]
    sql_trigger_value: select current_date
    sql: |
      SELECT
        orders.id
        ,count(foo.id) 
            AS number_subsequent_orders
       ,min(foo.created_at)
            AS next_order_date
        ,min(foo.id) as next_order_id
      
      FROM      thelook.orders orders
      LEFT JOIN thelook.orders foo
      ON        orders.user_id = foo.user_id
      AND       orders.created_at < foo.created_at
      GROUP BY  1
      

  fields:
  - measure: count
    type: count
    hidden: true
    drill_fields: detail*
    
  - dimension: has_subsequent_order
    type: yesno
    sql: ${next_order_id} > 0
  

  - dimension: order_id
    type: number
    hidden: true
    primary_key: true
    sql: ${TABLE}.id

  - dimension: number_subsequent_orders
    type: number
    sql: ${TABLE}.number_subsequent_orders
    
  - dimension: days_until_next_order
    type: number
    sql: datediff('day',${orders.created_at}, ${TABLE}.next_order_date)
    
  - dimension: repeat_orders_within_30d
    type: yesno
    sql: ${days_until_next_order} <= 30
    
  - measure: count_with_repeat_purchase_within_30d
    type: count
    filters:
      repeat_orders_within_30d: 'Yes'
      
  - measure: 30_day_repeat_purchase_rate
    type: number
    value_format: '#.#\%'
    sql: 100.0 * ${count_with_repeat_purchase_within_30d} / nullif(${orders.count},0)

    
  - dimension: next_order_date_raw
    hidden: true
    sql: ${TABLE}.next_order_date

  - dimension: next_order_id
    type: number
    hidden: true
    sql: ${TABLE}.next_order_id

  sets:
    detail:
      - id
      - number_subsequent_orders
      - next_order_date
      - next_order_id

