- view: sessions
  derived_table:
    indexes: [session_id]
    sql_trigger_value: select curdate()
    sql: |
      select
      session_id
      ,min(created_at) as session_start
      ,max(created_at) as session_end
      ,count(*) as number_of_events_in_session
      ,sum(case when event_type in ('Category','Brand') then 1 end) as browse_events
      ,sum(case when event_type = 'Product' then 1 end) as product_events
      ,sum(case when event_type = 'Cart' then 1 end) as cart_events
      ,sum(case when event_type = 'Purchase' then 1 end) as purchase_events
      ,max(user_id) as session_user_id
      ,min(id) as landing_event_id
      ,max(id) as bounce_event_id
      
      from events
      group by session_id
      

  fields:
  
  #####  Basic Web Info  ########  
  
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: session_id
    type: string
    primary_key: true
    sql: ${TABLE}.session_id

  - dimension: session_user_id
    sql: ${TABLE}.session_user_id

  - dimension: landing_event_id
    sql: ${TABLE}.landing_event_id
    
  - dimension: bounce_event_id
    sql: ${TABLE}.bounce_event_id

  - dimension_group: session_start
    type: time
    timeframes: [time, date, week, month, hour_of_day, day_of_week]
    sql: ${TABLE}.session_start

  - dimension_group: session_end
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.session_end
    
  - dimension: duration
    label: 'Duration (sec)'
    type: number
    sql: DATEDIFF('second', ${TABLE}.session_start, ${TABLE}.session_end)
    
  - measure: average_duration
    label: 'Average Duration (sec)'
    type: average
    decimals: 1
    sql: ${duration}
  
  - dimension: duration_seconds_tier
    label: 'Duration Tier (sec)'
    type: tier
    tiers: [10, 30, 60, 120, 300]
    style: integer
    sql: ${duration}


  #####  Bounce Information  ########

  - dimension: is_bounce_session
    type: yesno
    sql: ${number_of_events_in_session} = 1
    
  - measure: count_bounce_sessions
    type: count
    filters:
      is_bounce_session: 'Yes'
      
  - measure: percent_bounce_sessions
    type: number
    value_format: '#.#\%'
    sql: 100.0 * ${count_bounce_sessions} / nullif(${count},0)
    
  
  ####### Session by event types included  ########
  
  - dimension: number_of_browse_events_in_session
    type: number
    hidden: true
    sql: ${TABLE}.browse_events

  - dimension: number_of_product_events_in_session
    type: number
    hidden: true
    sql: ${TABLE}.product_events

  - dimension: number_of_cart_events_in_session
    type: number
    hidden: true
    sql: ${TABLE}.cart_events

  - dimension: number_of_purchase_events_in_session
    type: number
    hidden: true
    sql: ${TABLE}.purchase_events
  
  - dimension: includes_browse
    type: yesno
    sql: ${number_of_browse_events_in_session} > 0
    
  - dimension: includes_product
    type: yesno
    sql: ${number_of_product_events_in_session} > 0
    
  - dimension: includes_cart
    type: yesno
    sql: ${number_of_cart_events_in_session} > 0
    
  - dimension: includes_purchase
    type: yesno
    sql: ${number_of_purchase_events_in_session} > 0

  - measure: count_with_cart
    type: count
    filters:
      includes_cart: 'Yes'
      
  - measure: count_with_purchase
    type: count
    filters:
      includes_purchase: 'Yes'
      


  - dimension: number_of_events_in_session
    type: number
    sql: ${TABLE}.number_of_events_in_session

  ####### Linear Funnel   ########
    
  - dimension: furthest_funnel_step
    sql: |
      CASE
      WHEN ${number_of_purchase_events_in_session} > 0 THEN '(5) Purchase'
      WHEN ${number_of_cart_events_in_session} > 0 THEN '(4) Add to Cart'
      WHEN ${number_of_product_events_in_session} > 0 THEN '(3) View Product'
      WHEN ${number_of_browse_events_in_session} > 0 THEN '(2) Browse'
      ELSE '(1) Land'
      END

  - measure: all_sessions
    view_label: 'Funnel View'
    label: '(1) All Sessions'
    type: count
    
  - measure: count_browse_or_later
    view_label: 'Funnel View'
    label: '(2) Browse or later'
    type: count
    filters:
        furthest_funnel_step: |
          '(2) Browse','(3) View Product','(4) Add to Cart','(5) Purchase'

    
  - measure: count_product_or_later
    view_label: 'Funnel View'
    label: '(3) View Product or later'
    type: count
    filters:
        furthest_funnel_step: |
          '(3) View Product','(4) Add to Cart','(5) Purchase'

    
  - measure: count_cart_or_later
    view_label: 'Funnel View'
    label: '(4) Add to Cart or later'
    type: count
    filters:
        furthest_funnel_step: |
          '(4) Add to Cart','(5) Purchase'
          
    
  - measure: count_purchase
    view_label: 'Funnel View'
    label: '(5) Purchase'
    type: count
    filters:
        furthest_funnel_step: |
         '(5) Purchase'          

  - measure: cart_to_checkout_conversion
    view_label: 'Funnel View'
    type: number
    value_format: '#.#\%'
    sql: 100.0 * ${count_purchase} / nullif(${count_cart_or_later},0)

  - measure: overall_conversion
    view_label: 'Funnel View'
    type: number
    value_format: '#.#\%'
    sql: 100.0 * ${count_purchase} / nullif(${count},0)



  sets:
    detail:
      - session_id
      - session_start_time
      - session_end_time
      - number_of_events_in_session
      - purchase_events
      - cart_events













# - view: sessions_old
#   derived_table:
#     sql_trigger_value: SELECT DATE(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', GETDATE()))
#     distkey: user_id
#     sortkeys: [session_start]
#     sql: |
#       SELECT
#         lag.e_tstamp AS session_start
#         , lag.idle_time AS idle_time
#         , lag.user_id AS user_id
#         , lag.ip_address AS ip_address
#         , ROW_NUMBER () OVER (ORDER BY lag.e_tstamp) AS unique_session_id
#         , RANK() OVER(PARTITION BY COALESCE(lag.user_id, lag.ip_address) ORDER BY lag.e_tstamp) AS session_sequence
#         , COALESCE(
#               LEAD(lag.e_tstamp) OVER (PARTITION BY lag.user_id, lag.ip_address ORDER BY lag.e_tstamp)
#             , '3000-01-01') AS next_session_start
#       FROM
#           ( SELECT
#                 logs.rtime AS e_tstamp
#               , logs.user_id AS user_id
#               , logs.ip AS ip_address
#               , DATEDIFF(
#                   minute, 
#                   LAG(logs.rtime) OVER ( PARTITION BY logs.user_id, logs.ip ORDER BY logs.rtime)
#                 , logs.rtime) AS idle_time
#             FROM logs.log as logs
#             WHERE ((logs.rtime) >= (DATEADD(day,-29, DATE_TRUNC('day',GETDATE()) )) 
#                   AND (logs.rtime) < (DATEADD(day,30, DATEADD(day,-29, DATE_TRUNC('day',GETDATE()) ) )))
#             ) AS lag
#       WHERE (lag.idle_time > 5 OR lag.idle_time IS NULL)  -- session threshold
# 
# 
#   fields:
#     - measure: count
#       type: count
#       drill_fields: [session_id, user_id, users.name, start_time, session_facts.session_duration, session_facts.farthest_funnel_step_of_session, events.count]
# 
#     
#     - dimension: user_event_sequence
# #       primary_key: true
#       hidden: true
#       sql: ${user_id} ||'-'|| ${session_sequence_by_user}
#   
#     - dimension: session_id
#       type: int
#       primary_key: true
#       sql: ${TABLE}.unique_session_id
# 
#     - measure: all_session
#       label: '(1) All Sessions'
#       description: 'All session that make it to step 1 or farther (visit website)'
#       required_joins: [session_facts]
#       type: count
#       drill_fields: [user_id, session_sequence_by_user, start_time, session_facts.session_duration, session_facts.farthest_funnel_step_of_session, events.count]
# 
#     - measure: count_with_browse
#       label: '(2) Browse'
#       description: 'All session that make it to step 2 or farther (browse product)'
#       type: count
#       required_joins: [session_facts]
#       drill_fields: [user_id, session_sequence_by_user, start_time, session_facts.session_duration, session_facts.farthest_funnel_step_of_session, events.count]
#       filters:
#         session_facts.farthest_funnel_step_of_session: |
#           '2 - Browse','3 - Add to Cart','4 - Checkout'
# 
#     - measure: count_with_add_to_cart
#       label: '(3) Add to Cart'
#       description: 'All session that make it to step 3 or farther (add to cart)'
#       type: count
#       required_joins: [session_facts]
#       drill_fields: [user_id, session_sequence_by_user, start_time, session_facts.session_duration, session_facts.farthest_funnel_step_of_session, events.count]
#       filters:
#         session_facts.farthest_funnel_step_of_session: |
#           '3 - Add to Cart','4 - Checkout'
#     
#     - measure: count_with_checkout
#       label: '(4) Checkout'
#       type: count
#       description: 'All session that make it to step 4 (checkout)'
#       required_joins: [session_facts]
#       drill_fields: [user_id, session_sequence_by_user, start_time, session_facts.session_duration, session_facts.farthest_funnel_step_of_session, events.count]
#       filters:
#         session_facts.farthest_funnel_step_of_session: '4 - Checkout'
#         
#     - measure: cart_to_checkout_conversion
#       type: number
#       description: 'Count of sessions that make it to checkout, divided by count of sessions that make it cart'
#       required_joins: [session_facts]
#       drill_fields: [session_facts.farthest_funnel_step_of_session, count]
# 
#       value_format: '#.0%'
#       sql: ${count_with_checkout}*1.0 / nullif(${count_with_add_to_cart}*1.0,0)
#     
#     - dimension: user_id
#       hidden: true
#       sql: ${TABLE}.user_id
#     
#     - dimension: session_sequence_by_user
#       type: number
#       hidden: true
#       description: 'For a given user, what order did the sessions take place in? 1=First, 2=Second, etc'
#       sql: ${TABLE}.session_sequence
#     
#     - dimension_group: start
#       type: time
#       timeframes: [time, date, week, month, hour_of_day, day_of_week, hour]
#       sql: ${TABLE}.session_start
#       
#     - dimension_group: next_session_start
#       type: time
#       timeframes: [time, date, week, month]
#       sql: ${TABLE}.next_session_start
#     
#     