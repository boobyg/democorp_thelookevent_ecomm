view: sessions {
  derived_table: {
    sortkeys: ["session_id"]
    distribution: "session_id"
    sql_trigger_value: select max(created_at) from events ;;
    sql: SELECT
        session_id
        , MIN(created_at) AS session_start
        , MAX(created_at) AS session_end
        , COUNT(*) AS number_of_events_in_session
        , SUM(CASE WHEN event_type IN ('Category','Brand') THEN 1 END) AS browse_events
        , SUM(CASE WHEN event_type = 'Product' THEN 1 END) AS product_events
        , SUM(CASE WHEN event_type = 'Cart' THEN 1 END) AS cart_events
        , SUM(CASE WHEN event_type = 'Purchase' THEN 1 end) AS purchase_events
        , MAX(user_id) AS session_user_id
        , MIN(id) AS landing_event_id
        , MAX(id) AS bounce_event_id
      FROM events
      GROUP BY session_id
       ;;
  }

  #####  Basic Web Info  ########

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: session_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.session_id ;;
  }

  dimension: session_user_id {
    sql: ${TABLE}.session_user_id ;;
  }

  dimension: landing_event_id {
    sql: ${TABLE}.landing_event_id ;;
  }

  dimension: bounce_event_id {
    sql: ${TABLE}.bounce_event_id ;;
  }

  dimension_group: session_start {
    type: time
#     timeframes: [time, date, week, month, hour_of_day, day_of_week]
    sql: ${TABLE}.session_start ;;
  }

  dimension_group: session_end {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.session_end ;;
  }

  dimension: duration {
    label: "Duration (sec)"
    type: number
    sql: DATEDIFF('second', ${session_start_raw}, ${session_end_raw}) ;;
  }

  measure: average_duration {
    label: "Average Duration (sec)"
    type: average
    value_format_name: decimal_2
    sql: ${duration} ;;
  }

  dimension: duration_seconds_tier {
    label: "Duration Tier (sec)"
    type: tier
    tiers: [10, 30, 60, 120, 300]
    style: integer
    sql: ${duration} ;;
  }

  #####  Bounce Information  ########

  dimension: is_bounce_session {
    type: yesno
    sql: ${number_of_events_in_session} = 1 ;;
  }

  measure: count_bounce_sessions {
    type: count

    filters: {
      field: is_bounce_session
      value: "Yes"
    }

    drill_fields: [detail*]
  }

  measure: percent_bounce_sessions {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${count_bounce_sessions} / nullif(${count},0) ;;
  }

  ####### Session by event types included  ########

  dimension: number_of_browse_events_in_session {
    type: number
    hidden: yes
    sql: ${TABLE}.browse_events ;;
  }

  dimension: number_of_product_events_in_session {
    type: number
    hidden: yes
    sql: ${TABLE}.product_events ;;
  }

  dimension: number_of_cart_events_in_session {
    type: number
    hidden: yes
    sql: ${TABLE}.cart_events ;;
  }

  dimension: number_of_purchase_events_in_session {
    type: number
    hidden: yes
    sql: ${TABLE}.purchase_events ;;
  }

  dimension: includes_browse {
    type: yesno
    sql: ${number_of_browse_events_in_session} > 0 ;;
  }

  dimension: includes_product {
    type: yesno
    sql: ${number_of_product_events_in_session} > 0 ;;
  }

  dimension: includes_cart {
    type: yesno
    sql: ${number_of_cart_events_in_session} > 0 ;;
  }

  dimension: includes_purchase {
    type: yesno
    sql: ${number_of_purchase_events_in_session} > 0 ;;
  }

  measure: count_with_cart {
    type: count

    filters: {
      field: includes_cart
      value: "Yes"
    }

    drill_fields: [detail*]
  }

  measure: count_with_purchase {
    type: count

    filters: {
      field: includes_purchase
      value: "Yes"
    }

    drill_fields: [detail*]
  }

  dimension: number_of_events_in_session {
    type: number
    sql: ${TABLE}.number_of_events_in_session ;;
  }

  ####### Linear Funnel   ########

  dimension: furthest_funnel_step {
    sql: CASE
      WHEN ${number_of_purchase_events_in_session} > 0 THEN '(5) Purchase'
      WHEN ${number_of_cart_events_in_session} > 0 THEN '(4) Add to Cart'
      WHEN ${number_of_product_events_in_session} > 0 THEN '(3) View Product'
      WHEN ${number_of_browse_events_in_session} > 0 THEN '(2) Browse'
      ELSE '(1) Land'
      END
       ;;
  }

  measure: all_sessions {
    view_label: "Funnel View"
    label: "(1) All Sessions"
    type: count
    drill_fields: [detail*]
  }

  measure: count_browse_or_later {
    view_label: "Funnel View"
    label: "(2) Browse or later"
    type: count

    filters: {
      field: furthest_funnel_step
      value: "(2) Browse,(3) View Product,(4) Add to Cart,(5) Purchase
      "
    }

    drill_fields: [detail*]
  }

  measure: count_product_or_later {
    view_label: "Funnel View"
    label: "(3) View Product or later"
    type: count

    filters: {
      field: furthest_funnel_step
      value: "(3) View Product,(4) Add to Cart,(5) Purchase
      "
    }

    drill_fields: [detail*]
  }

  measure: count_cart_or_later {
    view_label: "Funnel View"
    label: "(4) Add to Cart or later"
    type: count

    filters: {
      field: furthest_funnel_step
      value: "(4) Add to Cart,(5) Purchase
      "
    }

    drill_fields: [detail*]
  }

  measure: count_purchase {
    view_label: "Funnel View"
    label: "(5) Purchase"
    type: count

    filters: {
      field: furthest_funnel_step
      value: "(5) Purchase
      "
    }

    drill_fields: [detail*]
  }

  measure: cart_to_checkout_conversion {
    view_label: "Funnel View"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${count_purchase} / nullif(${count_cart_or_later},0) ;;
  }

  measure: overall_conversion {
    view_label: "Funnel View"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${count_purchase} / nullif(${count},0) ;;
  }

  set: detail {
    fields: [session_id, session_start_time, session_end_time, number_of_events_in_session, duration, number_of_purchase_events_in_session, number_of_cart_events_in_session]
  }
}

# - view: sessions_old
#   derived_table:
#     sql_trigger_value: SELECT DATE(CONVERT_TIMEZONE('UTC', 'America/Chicago', GETDATE()))
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
#       type: number
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
