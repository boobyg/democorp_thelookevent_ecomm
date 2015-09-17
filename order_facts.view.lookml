- view: order_facts
  derived_table:
    sql: |
      SELECT orders.id AS order_id
        , COUNT(*) AS items_in_order
        , SUM(sale_price) AS order_amount
        , SUM(inventory_items.cost) AS order_cost
        , RANK() OVER (PARTITION BY orders.user_id ORDER BY orders.created_at) AS order_sequence_number
      FROM order_items
      LEFT JOIN orders ON orders.id = order_items.order_id
      LEFT JOIN inventory_items ON order_items.inventory_item_id = inventory_items.id
      GROUP BY orders.id, orders.user_id, orders.created_at
    sortkeys: [order_id]
    distkey: order_id
    sql_trigger_value: SELECT MAX(id) FROM order_items
      
  fields:
  
## DIMENSIONS ##

  - dimension: order_id
    type: number
    hidden: true
    primary_key: true
    sql: ${TABLE}.order_id

  - dimension: items_in_order
    type: number
    sql: ${TABLE}.items_in_order

  - dimension: order_amount
    type: number
    sql: ${TABLE}.order_amount

  - dimension: order_cost
    type: number
    sql: ${TABLE}.order_cost

  - dimension: order_sequence_number
    type: number
    sql: ${TABLE}.order_sequence_number
  
  - dimension: is_first_purchase
    type: yesno
    sql: ${order_sequence_number} = 1

## MEASURES ##

  sets:
    detail:
      - order_id
      - items_in_order
      - order_amount
      - order_cost
      - order_sequence_number