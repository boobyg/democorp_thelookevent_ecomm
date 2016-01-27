- view: order_items
  sql_table_name: order_items
  fields:

########## IDs, Foreign Keys, Counts ########## 

  - dimension: id
    primary_key: true
    type: number
    sql: ${TABLE}.id

  - dimension: inventory_item_id
    type: number
    hidden: true
    sql: ${TABLE}.inventory_item_id

  - dimension: order_id
    type: number
    sql: ${TABLE}.order_id
  
  - dimension: user_id
    type: number
    hidden: true
    sql: ${TABLE}.user_id

  - measure: count
    type: count
    drill_fields: detail*

  - measure: order_count
    view_label: 'Orders'
    type: count_distinct
    drill_fields: detail*
    sql: ${order_id}
    
  - measure: first_purchase_count
    view_label: 'Orders'
    type: count_distinct
    sql: ${order_id}
    filters:
      order_facts.is_first_purchase: 'Yes'
    
########## Time Dimensions ########## 

  - dimension_group: returned
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.returned_at
    
  - dimension_group: shipped
    type: time
    timeframes: [date, week, month, raw]
    sql: ${TABLE}.shipped_at
    
  - dimension_group: delivered
    type: time
    timeframes: [date, week, month, raw]
    sql: ${TABLE}.delivered_at
    
  - dimension_group: created
    view_label: 'Orders'
    type: time
    timeframes: [time, hour, date, week, month, year, hour_of_day, day_of_week, month_num, raw, week_of_year]
    sql: ${TABLE}.created_at

  - dimension: months_since_signup
    view_label: 'Orders'
    type: number
    sql: DATEDIFF('month',${users.created_raw},${created_raw})
    

########## Logistics ##

  - dimension: status
    sql: ${TABLE}.status

  - dimension: days_to_process
    type: number
    decimals: 2
    sql: |
      CASE
        WHEN ${status} = 'Processing' THEN DATEDIFF('day',${created_raw},GETDATE())*1.0
        WHEN ${status} IN ('Shipped', 'Delivered') THEN DATEDIFF('day',${created_raw},${shipped_raw})*1.0
      END
  
  - dimension: shipping_time
    type: number
    decimals: 2
    sql: datediff('day',${shipped_raw},${delivered_raw})*1.0
    
  - measure: average_days_to_process
    type: average
    decimals: 4
    sql: ${days_to_process}
 
  - measure: average_shipping_time
    type: average
    decimals: 4
    sql: ${shipping_time}

########## Financial Information ########## 

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
  
  - measure: average_spend_per_user
    type: number
    sql: 1.0 * ${total_sale_price} / NULLIF(${users.count},0)


########## Repeat Purchase Facts ########## 

  - dimension: days_until_next_order
    type: number
    view_label: 'Repeat Purchase Facts'
    sql: DATEDIFF('day',${created_raw},${repeat_purchase_facts.next_order_raw})
    
  - dimension: repeat_orders_within_30d
    type: yesno
    view_label: 'Repeat Purchase Facts'
    sql: ${days_until_next_order} <= 30
    
  - measure: count_with_repeat_purchase_within_30d
    type: count
    view_label: 'Repeat Purchase Facts'
    filters:
      repeat_orders_within_30d: 'Yes'
      
  - measure: 30_day_repeat_purchase_rate
    view_label: 'Repeat Purchase Facts'
    type: number
    value_format: '#.0\%'
    sql: 100.0 * ${count_with_repeat_purchase_within_30d} / NULLIF(${count},0)
    drill_fields: [products.brand, order_count, count_with_repeat_purchase_within_30d]

########## Sets ########## 

  sets:
    detail:
      - id
      - order_id
      - status
      - created_date
      - sale_price
      - products.brand
      - products.item_name
      - users.name
      - users.email
    