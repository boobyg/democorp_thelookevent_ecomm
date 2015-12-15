- view: user_session_facts
  derived_table:
    sql: |
      select user_id
            , count(*) as count_sessions
            , count(case when session_facts.farthest_funnel_step = '4 - Checkout' then session_facts.unique_session_id end) as count_purchasing_sessions
            , max(case when session_facts.farthest_funnel_step = '4 - Checkout' then sessions.session_start else null end) as latest_purchasing_session
            , max(case when session_facts.farthest_funnel_step = '3 - Add to Cart' then sessions.session_start else null end) as latest_add_to_cart_session
      from ${sessions.SQL_TABLE_NAME} AS sessions
      left join ${session_facts.SQL_TABLE_NAME} AS session_facts ON sessions.unique_session_id = session_facts.unique_session_id
      group by 1

  fields:

  - dimension: user_id
    type: string
    primary_key: true
    hidden: true
    sql: ${TABLE}.user_id

  - dimension: total_session_count
    type: int
    sql: ${TABLE}.count_sessions

  - dimension: purchasing_session_count
    type: int
    sql: ${TABLE}.count_purchasing_sessions
  
  - dimension: is_loyal_customer
    type: yesno
    sql: | 
        ${total_session_count} > 2 and ${purchasing_session_count} > 0
  
  - dimension_group: latest_purchasing_session
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.latest_purchasing_session

  - dimension_group: latest_add_to_cart_session
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.latest_add_to_cart_session

  sets:
    detail:
      - user_id
      - count_sessions
      - count_purchasing_sessions

