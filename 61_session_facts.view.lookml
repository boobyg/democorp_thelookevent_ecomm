# - view: session_facts
#   derived_table:
#     sql_trigger_value: SELECT DATE(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', GETDATE()))
#     sortkeys: [unique_session_id]
#     sql: |
#       SELECT
#             unique_session_id
#           , MIN(rtime) as session_start
#           , MAX(rtime) as session_end
#           , RANK() OVER (PARTITION BY COALESCE(user_id, ip) ORDER BY MIN(rtime)) AS session_sequence_for_user
#           , RANK() OVER (PARTITION BY COALESCE(user_id, ip) ORDER BY MIN(rtime) desc) AS inverse_session_sequence_for_user
#           , count(1) as number_of_events_in_session
#           , MAX(
#                 CASE
#                 WHEN dir1 = '/login'     THEN '1 - Login'
#                 WHEN ( dir1 = '/product' OR dir1 = '/category' OR dir1 = '/department')     THEN '2 - Browse'
#                 WHEN dir1 = '/add_to_cart'     THEN '3 - Add to Cart'
#                 WHEN dir1 = '/checkout'     THEN '4 - Checkout'
#                 END
#             ) as farthest_funnel_step
#           , session_landing_page_category
#           , session_exit_page_category
#           , session_landing_page
#           , session_exit_page
#           
# 
#       FROM ${events.SQL_TABLE_NAME} AS logs_with_session_info
#       GROUP BY
#             unique_session_id
#             , user_id
#             , ip
#             , session_landing_page_category
#             , session_exit_page_category
#             , session_landing_page
#             , session_exit_page
#         
#         
#      
#   fields:
# 
#   - dimension: session_id
#     type: int
#     primary_key: true
#     hidden: true
#     sql: ${TABLE}.unique_session_id
#   
#   - dimension_group: session_start
#     type: time
#     hidden: true
#     timeframes: [time, date]
#     sql: ${TABLE}.session_start  
# 
#   - dimension: days_since_first_session
#     type: number
#     sql: DATEDIFF('day', ${events.first_session_raw}, ${TABLE}.session_start)
#     
#   - dimension: landing_page_category
#     sql: ${TABLE}.session_landing_page_category
# 
#   - dimension: landing_page
#     sql: ${TABLE}.session_landing_page
#     
#   - dimension: bounce_page_category
#     sql: ${TABLE}.session_exit_page_category
#     
#   - dimension: bounce_page
#     sql: ${TABLE}.session_exit_page_category    
#   
#   - dimension_group: end
#     type: time
#     timeframes: [time, date]
#     sql: ${TABLE}.session_end
#     
#   - dimension: duration
#     label: 'Duration (sec)'
#     type: number
#     sql: DATEDIFF('second', ${TABLE}.session_start, ${TABLE}.session_end)
#     
#   - measure: average_duration
#     label: 'Average Duration (sec)'
#     type: average
#     decimals: 1
#     sql: ${duration}
#   
#   - dimension: duration_seconds_tier
#     label: 'Duration Tier (sec)'
#     type: tier
#     tiers: [10, 30, 60, 120, 300]
#     style: integer
#     sql: ${duration}
#     
#   - dimension: session_sequence_for_user
#     type: int
#     description: 'For a given user, what order did the sessions take place in? 1=First, 2=Second, etc'
#     sql: ${TABLE}.session_sequence_for_user
#   
#   - dimension: is_first_session
#     type: yesno
#     sql: ${session_sequence_for_user} = 1
#   
#   - measure: count_first_sessions
#     type: count
#     filter: 
#       is_first_session: yes
#   
#   - measure: percent_first_sessions
#     type: number
#     sql: 100*(${count_first_sessions}::float/NULLIF(${sessions.count},0))
#     value_format: '0.00\%'
#     
#   - dimension: inverse_session_sequence_for_user
#     type: int
#     description: 'For a given user, what order did the sessions take place in? 1=Last, 2=Second-to-Last, etc'
#     sql: ${TABLE}.inverse_session_sequence_for_user
# 
#   - dimension: number_of_events_in_session
#     type: int
#     sql: ${TABLE}.number_of_events_in_session
# 
#   - dimension: farthest_funnel_step_of_session
#     sql: ${TABLE}.farthest_funnel_step
#   
#   - dimension: is_purchasing_session
#     type: yesno
#     sql: ${farthest_funnel_step_of_session} = '4 - Checkout'
#   