- view: raw_logs
  sql_table_name: logs.log
  fields:

  - dimension: browser
    sql: ${TABLE}.browser

  - dimension: classb
    sql: ${TABLE}.classb

  - dimension: dir_1
    sql: ${TABLE}.dir1

  - dimension: dir_2
    sql: ${TABLE}.dir2

  - dimension: dir_3
    sql: ${TABLE}.dir3

  - dimension: identd
    sql: ${TABLE}.identd
    hidden: true

  - dimension: ip
    sql: ${TABLE}.ip

  - dimension: os
    sql: ${TABLE}.os

  - dimension: product_id
    sql: ${TABLE}.product_id

  - dimension: protocol
    sql: ${TABLE}.protocol

  - dimension: referer
    sql: ${TABLE}.referer

  - dimension_group: request
    type: time
    timeframes: [time, date, hour, time_of_day, hour_of_day, week, day_of_week_index, day_of_week]
    sql: ${TABLE}.rtime
    
  - dimension: size_mb
    sql: ${TABLE}.size::float/1000000

  - dimension: status
    sql: ${TABLE}.status

  - dimension: substring
    sql: ${TABLE}.substring

  - dimension: uri
    sql: ${TABLE}.uri

  - dimension: useragent
    sql: ${TABLE}.useragent

  - dimension: userid
    sql: ${TABLE}.userid
    hidden: true
  
  - dimension: user_id
    sql: ${TABLE}.user_id

# MEASURES #

  - measure: request_count
    type: count
    drill_fields: detail*
  
  - measure: request_count_os_x
    type: count
    drill_fields: detail*
    filters:
      os: "Mac OS X"

  - measure: request_count_windows
    type: count
    drill_fields: detail*
    filters:
      os: "Windows"

  - measure: request_count_linux
    type: count
    drill_fields: detail*
    filters:
      os: "Linux (other)"

  - measure: request_count_other
    type: count
    drill_fields: detail*
    filters:
      os: -"Mac OS X",-"Windows",-"Linux (other)"
  
  - measure: request_count_m
    type: number
    decimals: 1
    sql: ${request_count}/1000000.0
    html: |
      {{ rendered_value }}M
  
  - measure: unique_users
    type: count_distinct
    sql: ${user_id}
  
  - measure: unique_ips
    type: count_distinct
    sql: ${ip}
    
  - measure: unique_visitors_m
    type: number
    sql: count (distinct ${ip}) / 1000000.0
    decimals: 3
    drill_fields: [request_date, unique_ips]

  - measure: unique_visitors_k
    type: number
    sql: count (distinct ${ip}) / 1000.0
    decimals: 3
    drill_fields: [request_date, unique_ips]

  - measure: mau
    hidden: yes
    type: count_distinct
    sql: ${ip}
    filters:
      request_date: last 30 days
      
  
  - measure: mau_m
    type: number
    decimals: 1
    sql: ${mau}/1000000.0
    html: |
      {{ rendered_value }}M

  - measure: wau
    hidden: yes
    type: count_distinct
    sql: ${ip}
    filters:
      request_date: last 7 days
  
  - measure: wau_k
    type: number
    decimals: 1
    sql: ${wau}/1000.0
    html: |
      {{ rendered_value }}k

  - measure: dau
    hidden: yes
    type: count_distinct
    sql: ${ip}
    filters:
      request_date: 1 day ago
  
  - measure: dau_k
    type: number
    decimals: 1
    sql: ${dau}/1000.0
    html: |
      {{ rendered_value }}k

  - measure: requests_per_user
    type: number
    decimals: 2
    sql: ${request_count}/${unique_users}
  
  - measure: total_bandwidth_mb
    type: number
    decimals: 2
    sql: sum(${size_mb})


  sets:
    detail:
      - ip
      - identd
      - userid
      - rtime
      - method
      - uri
      - protocol
      - status
      - size
      - referer
      - useragent
