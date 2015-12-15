- view: users
  sql_table_name: users
  fields:

## Demographics ##

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension: first_name
    hidden: true
    sql: ${TABLE}.first_name
      
  - dimension: last_name
    hidden: true
    sql: ${TABLE}.last_name
  
  - dimension: name
    sql: ${first_name} || ' ' || ${last_name}

  - dimension: age
    type: int
    sql: ${TABLE}.age

  - measure: average_age
    type: average
    decimals: 2
    sql: ${age}
    drill_fields: detail*  
  
  - dimension: age_tier
    type: tier
    tiers: [0,10,20,30,40,50,60,70]
    style: integer
    sql: ${age}

  - dimension: gender
    sql: ${TABLE}.gender
    
  - dimension: gender_short
    sql: left(${gender},1)
  
  - dimension: user_image
    sql: ${image_file}
    html: <img src="{{ value }}" width="100" height="100"/>  

  - dimension: email
    html: |
      {{ linked_value }}
      <a href="/dashboards/31?email={{ value | encode_uri }}" target="_new">
      <img src="/images/qr-graph-line@2x.png" height=20 width=20></a>  

  - dimension: image_file
    hidden: true
    sql: ('http://www.looker.com/_content/docs/99-hidden/images/'||${gender_short}||'.jpg') 
    
## Demographics ##

  - dimension: city
    sql: ${TABLE}.city

  - dimension: state
    sql: ${TABLE}.state

  - dimension: zip
    type: zipcode
    sql: ${TABLE}.zip
    
  - dimension: country
    sql: ${TABLE}.country

  - dimension: location
    type: location
    sql_latitude: ${TABLE}.latitude
    sql_longitude: ${TABLE}.longitude

  - dimension: approx_location
    type: location
    sql_latitude: round(${TABLE}.latitude,1)
    sql_longitude: round(${TABLE}.longitude,1)

    
## Other User Information ##

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.created_at

  - dimension: history
    sql: ${TABLE}.id
    html: |
      <a href="/explore/thelook/order_items?fields=order_items.detail*&f[users.id]={{ value }}">Order History</a>
  
  - dimension: traffic_source
    sql: ${TABLE}.traffic_source


## MEASURES ##

  - measure: count
    type: count
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
    

      
    
