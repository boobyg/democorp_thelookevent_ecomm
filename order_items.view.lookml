- view: order_items
  sql_table_name: thelook.order_items
  fields:

## DIMENSIONS ##

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension: inventory_item_id
    type: int
    hidden: true
    sql: ${TABLE}.inventory_item_id

  - dimension: order_id
    type: int
    hidden: true
    sql: ${TABLE}.order_id

  - dimension_group: returned
    type: time
    timeframes: [time, date, week, month, yesno]
    sql: ${TABLE}.returned_at

  - dimension: sale_price
    type: number
    value_format: '$#,##0.00'
    sql: ${TABLE}.sale_price
  
  - dimension: gross_margin
    type: number
    value_format: '$#,##0.00'
    sql: ${sale_price} - ${inventory_items.cost}

  - dimension: item_gross_margin_percentage
    type: number
    value_format: '#.0\%'
    sql: 100.0 * ${gross_margin}/${sale_price}

  - dimension: item_gross_margin_percentage_tier
    type: tier
    sql: ${item_gross_margin_percentage}
    tiers: [0,10,20,30,40,50,60,70,80,90]

## MEASURES ##

  - measure: count
    type: count
    drill_fields: detail*
  
  - measure: total_sale_price
    type: sum
    value_format: '$#,##0.00'
    sql: ${sale_price}
    drill_fields: detail*
  
  - measure: total_gross_margin
    type: sum
    value_format: '$#,##0.00'
    sql: ${gross_margin}
    drill_fields: detail*
  
  - measure: average_sale_price
    type: average
    value_format: '$#,##0.00'
    sql: ${sale_price}
    drill_fields: detail*
  
  - measure: average_gross_margin
    type: average
    value_format: '$#,##0.00'
    sql: ${gross_margin}
    drill_fields: detail*
  
  - measure: total_gross_margin_percentage
    type: number
    value_format: '#.0\%'
    sql: 100.0 * ${total_gross_margin}/${total_sale_price}
    

  sets:
    detail:
      - id
      - orders.id
      - orders.status
      - orders.created_time
      - sale_price
      - products.brand
      - products.item_name
      - users.name
      - users.email
    