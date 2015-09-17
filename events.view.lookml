- view: events
  derived_table:
    sql_trigger_value: SELECT GETDATE()
    sortkeys: [rtime]
    distkey: unique_session_id
    sql: |
      SELECT
            ROW_NUMBER() OVER (ORDER BY log.rtime) AS event_id
          , log.product_id AS raw_product_id 
          , CASE
             WHEN dir1 = '/checkout' 
             THEN LAG(log.product_id) IGNORE NULLS OVER (PARTITION BY log.user_id, log.ip ORDER BY log.rtime)
             ELSE log.product_id
             END as product_id
          , log.useragent
          , log.size  
          , log.status  
          , log.uri 
          , log.identd  
          , log.ip  
          , log.user_id 
          , log.classb  
          , log.os  
          , log.browser 
          , log.referer 
          , log.protocol
          , log.dir3
          , log.dir2
          , log.dir1  
          , log.method
          , log.rtime 
          , sessions.unique_session_id
          , RANK() OVER (PARTITION BY unique_session_id ORDER BY log.rtime) AS event_sequence_within_session
          , RANK() OVER (PARTITION BY unique_session_id ORDER BY log.rtime desc) AS inverse_event_sequence_within_session
          , FIRST_VALUE (dir1)  OVER (PARTITION BY unique_session_id ORDER BY rtime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_landing_page_category
          , LAST_VALUE  (dir1)  OVER (PARTITION BY unique_session_id ORDER BY rtime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_exit_page_category
          , FIRST_VALUE (uri)   OVER (PARTITION BY unique_session_id ORDER BY rtime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_landing_page
          , LAST_VALUE  (uri)   OVER (PARTITION BY unique_session_id ORDER BY rtime ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS session_exit_page
          , MIN(rtime) OVER (PARTITION BY log.user_id, log.ip) AS user_first_session
          , MIN(rtime) OVER (PARTITION BY log.user_id) AS user_first_session_test


      FROM logs.log AS log
      LEFT JOIN ${sessions.SQL_TABLE_NAME} AS sessions
        ON log.user_id = sessions.user_id
        AND log.ip = sessions.ip_address
        AND log.rtime >= sessions.session_start
        AND log.rtime < sessions.next_session_start
      WHERE 
        ((log.rtime) >= (DATEADD(day,-29, DATE_TRUNC('day',GETDATE()) ))  AND (log.rtime) < (DATEADD(day,30, DATEADD(day,-29, DATE_TRUNC('day',GETDATE()) ) )))
        
        
     
  fields:

  - dimension: event_id
    type: int
    primary_key: true
    sql: ${TABLE}.event_id
    
  - dimension: session_id
    type: int
    hidden: true
    sql: ${TABLE}.unique_session_id
    
#   - dimension_group: user_first_session
#     type: time
#     timeframes: [time, date]
#     sql: ${TABLE}.user_first_session

  - dimension_group: first_session
    type: time
    view_label: Visitors
    timeframes: [time, date, week]
    sql: ${TABLE}.user_first_session_test
    
  - dimension: first_session_raw
    hidden: true
    sql: ${TABLE}.user_first_session_test

  - dimension: ip
    label: 'IP Address'
    view_label: Visitors  
    sql: ${TABLE}.ip

  - dimension: identd
    hidden: true
    sql: ${TABLE}.identd

#   - dimension: userid
#     sql: ${TABLE}.userid

  - dimension_group: request
    type: time
    timeframes: [time, date, hour, time_of_day, hour_of_day, week, day_of_week_index, day_of_week]
    sql: ${TABLE}.rtime

  - dimension: method
    hidden: true
    sql: ${TABLE}.method
    
  - dimension: event_sequence_within_session
    type: int
    description: 'Within a given session, what order did the events take place in? 1=First, 2=Second, etc'
    sql: ${TABLE}.event_sequence_within_session
    
  - dimension: is_entry_event
    type: yesno
    description: 'Yes indicates this was the entry point / landing page of the session'
    sql: ${event_sequence_within_session} = 1

  - dimension: inverse_event_sequence_within_session
    type: int
    description: 'Within a given session, what order did the events take place in? 1=Last, 2=Second-to-Last, etc'
    sql: ${TABLE}.inverse_event_sequence_within_session

  - dimension: is_exit_event
    type: yesno
    description: 'Yes indicates this was the exit point / bounce page of the session'
    sql: ${inverse_event_sequence_within_session} = 1
    
  - measure: count_bounces
    type: count
    description: 'Count of events where those events were the bounce page for the session'
    filters:
      is_exit_event: 'Yes'
      
  - measure: bounce_rate
    type: number
    value_format: '#.00%'
    description: 'Percent of events where those events were the bounce page for the session, out of all events'
    sql: ${count_bounces}*1.0 / nullif(${count}*1.0,0)

  - dimension: full_page_url
    view_label: Webpages
    sql: ${TABLE}.uri

  - dimension: 1_level_url
    label: '1 Level URL'
    view_label: Webpages
    sql: ${TABLE}.dir1
    
  - dimension: 2_level_url
    label: '2 Level URL'
    view_label: Webpages
    sql: |
      CASE
      WHEN LENGTH(${dir2}) <> 0 THEN ${dir2}
      ELSE ${dir1}
      END

  - dimension: 3_level_url
    label: '3 Level URL'
    view_label: Webpages
    sql: |
      CASE
      WHEN LENGTH(${dir3}) <> 0 THEN ${dir3}
      WHEN LENGTH(${dir2}) <> 0 THEN ${dir2}
      ELSE ${dir1}
      END
    
  - dimension: funnel_step
    view_label: Webpages
    description: 'Login -> Browse -> Add to Cart -> Checkout'
    sql: |
      CASE
      WHEN ${1_level_url} = '/login'     THEN 'Login'
      WHEN ( ${1_level_url} = '/product' OR ${1_level_url} = '/category' OR ${1_level_url} = '/department')     THEN 'Browse'
      WHEN ${1_level_url} = '/add_to_cart'     THEN 'Add to Cart'
      WHEN ${1_level_url} = '/checkout'     THEN 'Checkout'
      END

  - measure: unique_visitors
    type: count_distinct
    description: 'Uniqueness determined by IP Address and User Login'
    view_label: Visitors
    sql: ${ip}

      
#   - measure: all_visitors
#     type: count_distinct
#     sql: ${ip}
# 
# 
#   - measure: browse_visitors
#     label: '(2) Visitors who Browse'
#     type: count_distinct
#     sql: ${ip}
#     filters:
#       funnel_step: 'Browse'
# 
#   - measure: add_to_cart_visitors
#     label: '(3) Visitors who Add to Cart'
#     type: count_distinct
#     sql: ${ip}
#     filters:
#       funnel_step: 'Add to Cart'

#   - measure: login_visitors
#     label: '(4) Visitors who Log In'
#     type: count_distinct
#     sql: ${ip}
#     filters:
#       funnel_step: 'Login'
# 
#   - measure: checkout_visitors
#     label: '(4) Visitors who Checkout'
#     type: count_distinct
#     sql: ${ip}
#     filters:
#       funnel_step: 'Checkout'
      
#   - measure: cart_to_checkout_conversion
#     type: number
#     value_format: '#.0%'
#     sql: ${checkout_visitors}*1.0 / nullif(${add_to_cart_visitors}*1.0,0)
    
  - dimension: has_user_id
    type: yesno
    view_label: Visitors
    description: 'Did the visitor sign in as a website user?'
    sql: ${users.id} > 0

  - dimension: dir1
    hidden: true
    sql: ${TABLE}.dir2

  - dimension: dir2
    hidden: true
    sql: ${TABLE}.dir2

  - dimension: dir3
    hidden: true
    sql: ${TABLE}.dir3

  - dimension: product_id
    type: int
    hidden: true
    sql: ${TABLE}.product_id
    
  - measure: c_d_prod_id
    type: count_distinct
    hidden: true
    sql: ${product_id}

  - dimension: protocol
    hidden: true
    sql: ${TABLE}.protocol

  - dimension: status_code
    description: 'Status code returned by web server'
    sql: ${TABLE}.status

  - dimension: size_mb
    label: 'Size (MB)'
    sql: ${TABLE}.size::float/1000000

  - dimension: referer
    hidden: true
    sql: ${TABLE}.referer

  - dimension: useragent
    hidden: true
    sql: ${TABLE}.useragent

  - dimension: browser
    view_label: Visitors
    sql: ${TABLE}.browser

  - dimension: os
    label: 'Operating System'
    view_label: Visitors
    sql: ${TABLE}.os

  - dimension: classb
    hidden: true
    sql: ${TABLE}.classb

  - dimension: user_id
    hidden: true
    sql: ${TABLE}.user_id
    
  - measure: count
    type: count
    drill_fields: [request_time, full_page_url]

  - measure: request_count_os_x
    hidden: true
    type: count
    drill_fields: detail*
    filters:
      os: "Mac OS X"

  - measure: request_count_windows
    hidden: true  
    type: count
    drill_fields: detail*
    filters:
      os: "Windows"

  - measure: request_count_linux
    hidden: true
    type: count
    drill_fields: detail*
    filters:
      os: "Linux (other)"

  - measure: request_count_other
    hidden: true
    type: count
    drill_fields: detail*
    filters:
      os: -"Mac OS X",-"Windows",-"Linux (other)"
  
  - measure: count_m
    label: 'Count (MM)'
    type: number
    decimals: 1
    sql: ${count}/1000000.0
    drill_fields: [count_m]
    value_format: '#.## "M"'
#     html: |
#       {{ rendered_value }}M
  
#   - measure: unique_users
#     type: count_distinct
#     sql: ${user_id}
#   
#   - measure: unique_ips
#     type: count_distinct
#     sql: ${ip}
    
  - measure: unique_visitors_m
    label: 'Unique Visitors (MM)'
    view_label: Visitors
    type: number
    sql: count (distinct ${ip}) / 1000000.0
    description: 'Uniqueness determined by IP Address and User Login'
    decimals: 3
    drill_fields: [request_date, unique_ips]

  - measure: unique_visitors_k
    label: 'Unique Visitors (k)'
    view_label: Visitors    
    type: number
    description: 'Uniqueness determined by IP Address and User Login'
    sql: count (distinct ${ip}) / 1000.0
    decimals: 3
    drill_fields: [request_date, unique_ips]


  - measure: requests_per_visitor
    type: number
    decimals: 2
    sql: ${count}/${unique_visitors}
  
  - measure: total_bandwidth_mb
    type: number
    decimals: 2
    sql: sum(${size_mb})

 