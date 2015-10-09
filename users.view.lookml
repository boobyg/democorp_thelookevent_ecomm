- view: users
  sql_table_name: thelook.users
  fields:

## DIMENSIONS ##

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension: age
    type: int
    sql: ${TABLE}.age
  
  - dimension: age_tier
    type: tier
    tiers: [0,10,20,30,40,50,60,70]
    style: integer
    sql: ${age}

  - dimension: city
    sql: ${TABLE}.city

  - dimension: country
    sql: ${TABLE}.country

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: email
    html: |
      {{ linked_value }}
      <a href="/dashboards/thelook/4_user_lookup?email={{ value | encode_uri }}" target="_new">
      <img src="/images/qr-graph-line@2x.png" height=20 width=20></a>  
      

  - dimension: gender
    sql: ${TABLE}.gender
  
  - dimension: history
    sql: ${TABLE}.id
    html: |
      <a href="/explore/thelook/order_items?fields=orders.detail*&f[users.id]={{ value }}">Orders</a>
      | <a href="/explore/thelook/order_items?fields=order_items.detail*&f[users.id]={{ value }}">Items</a>
  
  - dimension: first_name
    hidden: true
    sql: ${TABLE}.first_name
      
  - dimension: last_name
    hidden: true
    sql: ${TABLE}.last_name
  
  - dimension: name
    sql: ${first_name} || ' ' || ${last_name}

  - dimension: state
    sql: ${TABLE}.state

  - dimension: traffic_source
    sql: ${TABLE}.traffic_source

  - dimension: zip
    type: zipcode
    sql: ${TABLE}.zip

## MEASURES ##

  - measure: count
    type: count
    drill_fields: detail*
    
  - measure: average_age
    type: average
    decimals: 2
    sql: ${age}
    drill_fields: detail*

  - measure: count_percent_of_total
    label: Count (Percent of Total)
    type: percent_of_total
    decimals: 1
    sql: ${count}
    drill_fields: detail*
  
  sets: 
    detail:
      - id
      - name
      - email
      - age
      - created_date
      - orders.count
      - order_items.count
    
    