- view: events
  sql_table_name: events
  fields:

  - dimension: event_id
    type: number
    primary_key: true
    sql: ${TABLE}.id
    
  - dimension: session_id
    type: number
    hidden: true
    sql: ${TABLE}.session_id

  - dimension: ip
    label: 'IP Address'
    view_label: Visitors  
    sql: ${TABLE}.ip_address

  - dimension: user_id
    sql: ${TABLE}.user_id
    
  - dimension_group: event
    type: time
    timeframes: [time, date, hour, time_of_day, hour_of_day, week, day_of_week_index, day_of_week]
    sql: ${TABLE}.created_at
  
  - dimension: sequence_number
    type: number
    description: 'Within a given session, what order did the events take place in? 1=First, 2=Second, etc'
    sql: ${TABLE}.sequence_number
    
  - dimension: is_entry_event
    type: yesno
    description: 'Yes indicates this was the entry point / landing page of the session'
    sql: ${sequence_number} = 1

  - dimension: utm_source
    type: string
    label: 'UTM Source'
    sql: ${TABLE}.trafficsource
  
    dimension: is_exit_event
    description: 'Yes indicates this was the exit point / bounce page of the session'
    type: yesno
    sql: ${sequence_number} = ${sessions.number_of_events_in_session}
    
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
    sql: ${TABLE}.uri
    
  - dimension: viewed_product_id
    type: number
    sql: |
      CASE
        WHEN ${event_type} = 'Product' THEN right(uri,len(uri)-9)
      END
    
  - dimension: event_type
    sql: ${TABLE}.event_type

  - dimension: funnel_step
    description: 'Login -> Browse -> Add to Cart -> Checkout'
    sql: |
      CASE
        WHEN ${event_type} IN ('Login', 'Home') THEN '(1) Land'
        WHEN ${event_type} IN ('Category', 'Brand') THEN '(2) Browse Inventory'
        WHEN ${event_type} = 'Product' THEN '(3) View Product'
        WHEN ${event_type} = 'Cart' THEN '(4) Add Item to Cart'
        WHEN ${event_type} = 'Purchase' THEN '(5) Purchase'
      END

  - measure: unique_visitors
    type: count_distinct
    description: 'Uniqueness determined by IP Address and User Login'
    view_label: Visitors
    sql: ${ip}
    drill_fields: visitors*

  - dimension: location
    type: location
    view_label: Visitors
    sql_latitude: ${TABLE}.latitue
    sql_longitude: ${TABLE}.longitude

  - dimension: approx_location
    type: location
    view_label: Visitors
    sql_latitude: round(${TABLE}.latitude,1)
    sql_longitude: round(${TABLE}.longitude,1)
    
  - dimension: has_user_id
    type: yesno
    view_label: Visitors
    description: 'Did the visitor sign in as a website user?'
    sql: ${users.id} > 0
    
  - dimension: browser
    view_label: Visitors
    sql: ${TABLE}.browser

  - dimension: os
    label: 'Operating System'
    view_label: Visitors
    sql: ${TABLE}.os
  
  - measure: count
    type: count
    drill_fields: simple_page_info*

  - measure: sessions_count
    type: count_distinct
    sql: ${session_id}  

  - measure: count_m
    label: 'Count (MM)'
    type: number
    decimals: 1
    hidden: true
    sql: ${count}/1000000.0
    drill_fields: simple_page_info*
    value_format: '#.## "M"'
    
  - measure: unique_visitors_m
    label: 'Unique Visitors (MM)'
    view_label: Visitors
    type: number
    sql: count (distinct ${ip}) / 1000000.0
    description: 'Uniqueness determined by IP Address and User Login'
    decimals: 3
    hidden: true
    drill_fields: visitors*

  - measure: unique_visitors_k
    label: 'Unique Visitors (k)'
    view_label: Visitors    
    type: number
    hidden: true
    description: 'Uniqueness determined by IP Address and User Login'
    sql: count (distinct ${ip}) / 1000.0
    decimals: 3
    drill_fields: visitors*


  sets:
    simple_page_info:
      - event_id
      - event_time
      - event_type
      - os
      - browser
      - full_page_url
      - user_id
      - funnel_step
  
    visitors:
      - ip
      - os
      - browser
      - user_id
      - count
 