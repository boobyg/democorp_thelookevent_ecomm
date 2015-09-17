- view: sessions
  derived_table:
    sql_trigger_value: SELECT GETDATE()
    distkey: user_id
    sortkeys: [session_start]
    sql: |
      SELECT
        lag.e_tstamp AS session_start
        , lag.idle_time AS idle_time
        , lag.user_id AS user_id
        , lag.ip_address AS ip_address
        , ROW_NUMBER () OVER (ORDER BY lag.e_tstamp) AS unique_session_id
        , RANK() OVER(PARTITION BY lag.user_id, lag.ip_address ORDER BY lag.e_tstamp) AS session_sequence
        , COALESCE(
              LEAD(lag.e_tstamp) OVER (PARTITION BY lag.user_id, lag.ip_address ORDER BY lag.e_tstamp)
            , '3000-01-01') AS next_session_start
      FROM
          ( SELECT
                logs.rtime AS e_tstamp
              , logs.user_id AS user_id
              , logs.ip AS ip_address
              , DATEDIFF(
                  minute, 
                  LAG(logs.rtime) OVER ( PARTITION BY logs.user_id, logs.ip ORDER BY logs.rtime)
                , logs.rtime) AS idle_time
            FROM logs.log as logs
            WHERE ((logs.rtime) >= (DATEADD(day,-29, DATE_TRUNC('day',GETDATE()) )) 
                  AND (logs.rtime) < (DATEADD(day,30, DATEADD(day,-29, DATE_TRUNC('day',GETDATE()) ) )))
            ) AS lag
      WHERE (lag.idle_time > 5 OR lag.idle_time IS NULL)  -- session threshold


  fields:
    - measure: count
      type: count
      drill_fields: [user_id, session_sequence_by_user, start_time, session_facts.session_duration, session_facts.farthest_funnel_step_of_session, events.count]

    
    - dimension: user_event_sequence
#       primary_key: true
      hidden: true
      sql: ${user_id} ||'-'|| ${session_sequence_by_user}
  
    - dimension: session_id
      type: int
      primary_key: true
      sql: ${TABLE}.unique_session_id

    - measure: all_session
      label: '(1) All Sessions'
      description: 'All session that make it to step 1 or farther (visit website)'
      required_joins: [session_facts]
      type: count
      drill_fields: [user_id, session_sequence_by_user, start_time, session_facts.session_duration, session_facts.farthest_funnel_step_of_session, events.count]

    - measure: count_with_browse
      label: '(2) Browse'
      description: 'All session that make it to step 2 or farther (browse product)'
      type: count
      required_joins: [session_facts]
      drill_fields: [user_id, session_sequence_by_user, start_time, session_facts.session_duration, session_facts.farthest_funnel_step_of_session, events.count]
      filters:
        session_facts.farthest_funnel_step_of_session: |
          '2 - Browse','3 - Add to Cart','4 - Checkout'

    - measure: count_with_add_to_cart
      label: '(3) Add to Cart'
      description: 'All session that make it to step 3 or farther (add to cart)'
      type: count
      required_joins: [session_facts]
      drill_fields: [user_id, session_sequence_by_user, start_time, session_facts.session_duration, session_facts.farthest_funnel_step_of_session, events.count]
      filters:
        session_facts.farthest_funnel_step_of_session: |
          '3 - Add to Cart','4 - Checkout'
    
    - measure: count_with_checkout
      label: '(4) Checkout'
      type: count
      description: 'All session that make it to step 4 (checkout)'
      required_joins: [session_facts]
      drill_fields: [user_id, session_sequence_by_user, start_time, session_facts.session_duration, session_facts.farthest_funnel_step_of_session, events.count]
      filters:
        session_facts.farthest_funnel_step_of_session: '4 - Checkout'
        
    - measure: cart_to_checkout_conversion
      type: number
      description: 'Count of sessions that make it to checkout, divided by count of sessions that make it cart'
      required_joins: [session_facts]
      drill_fields: [session_facts.farthest_funnel_step_of_session, count]

      value_format: '#.0%'
      sql: ${count_with_checkout}*1.0 / nullif(${count_with_add_to_cart}*1.0,0)
    
    - dimension: user_id
      hidden: true
      sql: ${TABLE}.user_id
    
    - dimension: session_sequence_by_user
      type: number
      hidden: true
      description: 'For a given user, what order did the sessions take place in? 1=First, 2=Second, etc'
      sql: ${TABLE}.session_sequence
    
    - dimension_group: start
      type: time
      timeframes: [time, date, week, month, hour_of_day, day_of_week, hour]
      sql: ${TABLE}.session_start
      
    - dimension_group: next_session_start
      type: time
      timeframes: [time, date, week, month]
      sql: ${TABLE}.next_session_start
    
    