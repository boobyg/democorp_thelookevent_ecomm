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
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.created_at

  - dimension: email
    html: |
      {{ linked_value }}
      <a href="/dashboards/thelook/4_user_lookup?email={{ value | encode_uri }}" target="_new">
      <img src="/images/qr-graph-line@2x.png" height=20 width=20></a>  
      

  - dimension: gender
    sql: |
      CASE
      WHEN ${TABLE}.gender = 'm' THEN 'Male'
      WHEN ${TABLE}.gender = 'f' THEN 'Female'
      END
  
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
    
# kittens for certain demos

- explore: kitten_order_items
  label: 'Order Items (Kittens)'
  hidden: true
  extends: order_items 
  joins:
    - join: users
      from: kitten_users

- view: kitten_users
  extends: users
  fields:
  - dimension: portrait
    sql: GREATEST(MOD(${id}*97,867),MOD(${id}*31,881),MOD(${id}*72,893))
    type: int
    html: |
      <img height=120 width=120 src="http://placekitten.com/g/{{ value }}/{{ value }}">

  - dimension: kitten_name
    sql: CONCAT(${first_name},' ', ${TABLE}.last_name)

  - dimension: first_name
    sql_case:
      Bella: MOD(${id},24) = 23
      Bandit: MOD(${id},24) = 22
      Tigger: MOD(${id},24) = 21
      Boots: MOD(${id},24) = 20
      Chloe: MOD(${id},24) = 19
      Maggie: MOD(${id},24) = 18
      Pumpkin: MOD(${id},24) = 17
      Oliver: MOD(${id},24) = 16
      Sammy: MOD(${id},24) = 15
      Shadow: MOD(${id},24) = 14
      Sassy: MOD(${id},24) = 13
      Kitty: MOD(${id},24) = 12
      Snowball: MOD(${id},24) = 11
      Snickers: MOD(${id},24) = 10
      Socks: MOD(${id},24) = 9
      Gizmo: MOD(${id},24) = 8
      Jake: MOD(${id},24) = 7
      Lily: MOD(${id},24) = 6
      Charlie: MOD(${id},24) = 5
      Peanut: MOD(${id},24) = 4
      Zoe: MOD(${id},24) = 3
      Felix: MOD(${id},24) = 2
      Mimi: MOD(${id},24) = 1
      Jasmine: MOD(${id},24) = 0
  
  sets:
    detail: [SUPER*, kitten_name, portrait]
      
    