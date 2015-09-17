- view: funnels
  derived_table:
    sql_trigger_value: SELECT TRUNC(CONVERT_TIMEZONE('US/Pacific',GETDATE()))
    distkey: id
    sortkeys: [session_start_time]
    #persist_for: 24 hours
    sql: |
      SELECT
        ROW_NUMBER() OVER (ORDER BY min(l.rtime)) AS id,
        l.ip AS ip,
        l.user_id AS user_id,
        MIN(l.os) AS os,
        MIN(l.browser) AS browser,
        MIN(l.rtime) AS session_start_time,
        MAX(l.rtime) AS session_end_time,
        SUM(l.size::int) AS total_bytes_served,
        MIN(CASE WHEN l.dir1 = '/login' THEN 1 ELSE NULL END) AS log_in,
        MIN(CASE WHEN l.dir1 = '/product' THEN 1 ELSE NULL END) AS browse_product,
        MIN(CASE WHEN l.dir1 = '/add_to_cart' THEN 1 ELSE NULL END) AS add_to_cart,
        MIN(CASE WHEN l.dir1 = '/checkout' THEN 1 ELSE NULL END) AS checkout,
        MIN(CASE WHEN l.dir1 = '/logout' THEN 1 ELSE NULL END) AS logout,
        COUNT(1) AS session_length
      FROM logs.log AS l
      GROUP BY l.ip, l.user_id
      HAVING DATEDIFF(minute, min(l.rtime), max(l.rtime)) < 5

  fields:
  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension: user_id
    sql: ${TABLE}.user_id

  - dimension: os
    sql: ${TABLE}.os
    
  - dimension: browser
    sql: ${TABLE}.browser

  - dimension_group: session_start_time
    type: time
    timeframes: [hour, time, date, week, month]
    sql: ${TABLE}.session_start_time

  - dimension_group: session_end_time
    type: time
    timeframes: [hour, time, date, week, month]
    sql: ${TABLE}.session_end_time

  - dimension: total_kbytes_served
    type: number
    sql: ${TABLE}.total_bytes_served/1024.0
    decimals: 1

  - dimension: log_in
    sql: ${TABLE}.log_in
  
  - dimension: browse_product
    sql: ${TABLE}.browse_product
    
  - dimension: add_to_cart
    sql: ${TABLE}.add_to_cart
    
  - dimension: checkout
    sql: ${TABLE}.checkout
    
  - dimension: logout
    sql: ${TABLE}.logout
    
  - measure: count
    type: count
    drill_fields: drill_fields*

  - measure: step_1_logged_in
    type: count
    drill_fields: drill_fields*
    filters:
      log_in: 1
  
  - measure: step_2_browsed_product
    type: count
    drill_fields: drill_fields*
    filters:
      log_in: 1
      browse_product: 1

  - measure: step_3_added_to_cart
    type: count
    drill_fields: drill_fields*
    filters:
      log_in: 1
      browse_product: 1
      add_to_cart: 1

  - measure: step_4_checked_out
    type: count
    drill_fields: drill_fields*
    filters:
      log_in: 1
      browse_product: 1
      add_to_cart: 1
      checkout: 1

  - measure: step_5_logged_out
    type: count
    drill_fields: drill_fields*
    filters:
      log_in: 1
      browse_product: 1
      add_to_cart: 1
      checkout: 1
      logout: 1

  sets:
    drill_fields:
      - id
      - user_id
      - session_start_time_time
      - ip
      - session_length


