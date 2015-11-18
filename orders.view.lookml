- view: orders
  sql_table_name: thelook.orders
  fields:

## DIMENSIONS ##

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension_group: created
    type: time
    timeframes: [time, hour, date, week, month, year, hour_of_day, day_of_week, month_num, raw]
    sql: ${TABLE}.created_at
    
  - dimension: months_since_signup
    type: number
    sql: datediff('month',${users.created_raw},${created_raw})
    
  - dimension: created_at
    hidden: true
    sql: ${TABLE}.created_at
    
  - dimension: days_since_created
    type: number
    sql: datediff('day',${created_date},getdate())

  - dimension: status
    sql: ${TABLE}.status

  - dimension: traffic_source
    sql: ${TABLE}.traffic_source

  - dimension: user_id
    type: int
    hidden: true
    sql: ${TABLE}.user_id
  
  - dimension: profit
    type: number
    value_format: '$#,##0.00'
    sql: ${order_facts.order_amount} - ${order_facts.order_cost}

## MEASURES ##

  - measure: count
    type: count
    drill_fields: detail*
  
  - measure: first_purchase_count
    type: count
    drill_fields: detail*
    filters:
      order_facts.is_first_purchase: yes
      
  - measure: count_pending
    type: count 
    filters: 
      status: 'pending'
  
  - measure: average_profit
    type: average
    value_format: '$#,##0.00'
    sql: ${profit}
    drill_fields: detail*
  
  - measure: total_profit
    type: sum
    value_format: '$#,##0.00'
    sql: ${profit}
    drill_fields: detail*

  - measure: total_profit_k
    type: sum
    hidden: true
    value_format: '#.# "k"'
    sql: ${profit}/1000
    drill_fields: detail*
    
  - measure: count_percent_of_total
    label: Count (Percent of Total)
    type: percent_of_total
    drill_fields: detail*
    decimals: 2
    value_format: '#.0\%'
    sql: ${count}

  - measure: count_percent_of_previous
    label: Count (Percent Change)
    type: percent_of_previous
    drill_fields: detail*
    value_format: '#.0\%'
    decimals: 2
    sql: ${count}
    
  - measure: avg_days_in_status_pending
    type: avg
    sql: ${days_since_created}
    decimals: 1
    filters: 
      status: 'pending'
      
  - measure: max_days_in_status_pending
    type: max
    sql: ${days_since_created}
    decimals: 1
    filters: 
      status: 'pending'    

  sets:
    detail:
      - id
      - orders.id
      - orders.status
      - orders.created_time
      - order_facts.order_amount
      - order_items.count
      - order_facts.is_first_order
      - users.name
      - users.email
