- view: products
  sql_table_name: products
  fields:

  - dimension: id
    primary_key: true
    type: number
    sql: ${TABLE}.id

  - dimension: category
    sql: TRIM(${TABLE}.category)
    drill_fields: [item_name]


  - dimension: item_name
    sql: TRIM(${TABLE}.name)
    

  - dimension: brand
    sql: TRIM(${TABLE}.brand)
    links: 
      - label: Website
        url: http://www.google.com/search?q={{ value | url_encode }}+clothes&btnI
        icon_url: http://www.google.com/s2/favicons?domain=www.{{ value | url_encode }}.com
      - label: Facebook
        url: http://www.google.com/search?q=site:facebook.com+{{ value | url_encode }}+clothes&btnI
        icon_url: https://static.xx.fbcdn.net/rsrc.php/yl/r/H3nktOa7ZMg.ico
    drill_fields: [category, item_name]
    html: |
      {{ linked_value }}
      <a href="/dashboards/8?Brand%20Name={{ value | encode_uri }}" target="_new">
      <img src="/images/qr-graph-line@2x.png" height=20 width=20></a>

  - dimension: retail_price
    type: number
    sql: ${TABLE}.retail_price

  - dimension: department
    sql: TRIM(${TABLE}.department)

  - dimension: sku
    sql: ${TABLE}.sku

  - dimension: distribution_center_id
    type: number
    sql: ${TABLE}.distribution_center_id

## MEASURES ##

  - measure: count
    type: count
    drill_fields: detail*
  
  - measure: brand_count 
    type: count_distinct
    sql: ${brand}
    drill_fields:       
      - brand_name          # show the brand
      - detail2*            # a bunch of counts (see the set below)
      - -brand_count        # don't show the brand count, because it will always be 1
      
  - measure: category_count
    alias: [category.count]
    type: count_distinct
    sql: ${category}
    drill_fields: 
      - category_name
      - detail2*
      - -category_count     # don't show because it will always be 1
      
  - measure: department_count
    alias: [department.count]
    type: count_distinct
    sql: ${department}
    drill_fields: 
      - department_name
      - detail2*
      - -department_count   # don't show because it will always be 1


  sets:
    detail:
      - id
      - item_name
      - brand_name
      - category_name
      - department_name
      - retail_price
      - customers.count
      - orders.count
      - order_items.count
      - inventory_items.count
      
    detail2:
      - category_count
      - brand_count
      - department_count
      - count
      - customers.count
      - orders.count
      - order_items.count
      - inventory_items.count
      - products.count
    
    