view: user_session_facts {
  derived_table: {
    sql: SELECT
        user_id
        , COUNT(*) AS count_sessions
        , COUNT(CASE WHEN session_facts.farthest_funnel_step = '4 - Checkout' THEN session_facts.unique_session_id END) AS count_purchasing_sessions
        , MAX(CASE WHEN session_facts.farthest_funnel_step = '4 - Checkout' THEN sessions.session_start END) AS latest_purchasing_session
        , MAX(CASE WHEN session_facts.farthest_funnel_step = '3 - Add to Cart' THEN sessions.session_start END) AS latest_add_to_cart_session
      FROM ${sessions.SQL_TABLE_NAME} AS sessions
      LEFT JOIN ${session_facts.SQL_TABLE_NAME} AS session_facts
        ON sessions.unique_session_id = session_facts.unique_session_id
      GROUP BY 1
       ;;
  }

  dimension: user_id {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: total_session_count {
    type: number
    sql: ${TABLE}.count_sessions ;;
  }

  dimension: purchasing_session_count {
    type: number
    sql: ${TABLE}.count_purchasing_sessions ;;
  }

  dimension: is_loyal_customer {
    type: yesno
    sql: ${total_session_count} > 2 and ${purchasing_session_count} > 0
      ;;
  }

  dimension_group: latest_purchasing_session {
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.latest_purchasing_session ;;
  }

  dimension_group: latest_add_to_cart_session {
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.latest_add_to_cart_session ;;
  }

  set: detail {
    fields: [user_id, total_session_count, purchasing_session_count]
  }
}
