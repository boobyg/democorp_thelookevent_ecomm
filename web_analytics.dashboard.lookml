- dashboard: analytics_overview
  title: "(Event - 1) Web Analytics Overview"
  layout: tile
  tile_size: 50
  auto_run: true

  filters:
  - name: visit_date
    title: "Visit Date"
    type: date_filter
    default_value: 7 days
  
  - name: country
    title: "Country"
    type: field_filter
    explore: events
    field: countries.country_name
    default_value:
  
  - name: browser
    title: "Browser"
    type: field_filter
    explore: events
    field: events.browser
    default_value:  
  
  elements:
  - name: add_a_unique_name_430
    title: Total Page Views
    type: single_value
    model: thelook
    explore: events
    measures: [events.count_m]
    listen:
      visit_date: events.request_date
      country: countries.country_name
      browser: events.browser
    sorts: [events.request_count_m desc]
    limit: 500
    font_size: small
    height: 3
    width: 6



  - name: add_a_unique_name_258_1
    title: Visitors This Month
    type: single_value
    model: thelook
    listen:
      country: countries.country_name
      browser: events.browser
    filters:
      events.request_date: 30 days
    explore: events
    measures: [events.unique_visitors_m]
    sorts: [events.unique_visitors_m desc]
    limit: 500
    font_size: small
    height: 3
    width: 6
    value_format: '#.## "M"'

  - name: add_a_unique_name_258_2
    title: Visitors This Week
    type: single_value
    model: thelook
    listen:
      country: countries.country_name
      browser: events.browser
    filters:
      events.request_date: 7 days
    explore: events
    measures: [events.unique_visitors_k]
    sorts: [events.unique_visitors_k desc]
    limit: 500
    font_size: small
    height: 3
    width: 6
    value_format: '#.# "k"'

  - name: add_a_unique_name_258_3
    title: Visitors Last 24 Hours
    type: single_value
    model: thelook
    listen:
      country: countries.country_name
      browser: events.browser
    filters:
      events.request_date: 24 hours
    explore: events
    measures: [events.unique_visitors_k]
    sorts: [events.unique_visitors_k desc]
    limit: 500
    font_size: small
    height: 3
    width: 6
    value_format: '#.# "k"'


  - name: add_a_unique_name_0031
    title: Visits by Operating System
    type: looker_pie
    explore: events
    listen:
      visit_date: events.request_date
      country: countries.country_name
      browser: events.browser
    dimensions: [events.os]
    measures: [events.count]
    sorts: [events.count desc]
    limit: 50
    show_null_labels: false
#     colors: ['#651F81', '#C488DD', '#FEAC47', '#8ED1ED']
    width: 8
    height: 8

  - name: add_a_unique_name_0032
    title: Visits by Browser
    type: looker_pie
    explore: events
    listen:
      visit_date: events.request_date
      country: countries.country_name
      browser: events.browser
    dimensions: [events.browser]
    measures: [events.count]
    sorts: [events.count desc]
    limit: 50
    show_null_labels: false
#     colors: ['#651F81', '#C488DD', '#FEAC47', '#8ED1ED']
    width: 8
    height: 8

  - name: add_a_unique_name_682
    title: Visits by Landing Page
    type: looker_column
    model: thelook
    explore: sessions
    listen:
      visit_date: events.request_date
      country: users.country
      browser: events.browser
    dimensions: [session_facts.landing_page_category]
    sorts: [sessions.count desc]
    measures: [sessions.count]
    limit: 10
    stacking: ''
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    show_null_labels: false
    width: 8
    height: 8


  - name: add_a_unique_name_81
    title: Visitors by Hour and Day-Over-Day Percent Change
    type: looker_column
    model: thelook
    explore: events
    dimensions: [events.request_hour]
    measures: [events.unique_visitors]
    dynamic_fields:
    - table_calculation: pct_change_day_over_day_positive
      label: Pct Change Day over Day - Positive
      expression: if(round(100.0*${events.unique_visitors}/offset(${events.unique_visitors},-24)-100.0,2)>=0,round(100.0*${events.unique_visitors}/offset(${events.unique_visitors},-24)-100.0,2),null)
    - table_calculation: pct_change_day_over_day_negative
      label: Pct Change Day over Day - Negative
      expression: if(round(100.0*${events.unique_visitors}/offset(${events.unique_visitors},-24)-100.0,2)<0,round(100.0*${events.unique_visitors}/offset(${events.unique_visitors},-24)-100.0,2),null)
    filters:
      events.request_date: 4 days
    listen:
      country: countries.country_name
      browser: events.browser
    sorts: [events.request_hour]
    limit: 500
    series_types:
      events.unique_visitors: line
    show_null_points: true
    show_x_axis_label: true
    show_x_axis_ticks: false
    x_axis_gridlines: false
    show_value_labels: false
    show_view_names: false
    show_null_labels: false
    show_y_axis_labels: true
    show_y_axis_ticks: false
    y_axis_gridlines: true
    y_axis_orientation: [left, right, right]
    y_axis_max: ['10000', '3', '3']
    y_axis_min: ['-10000', '-3', '-3']
    y_axis_combined: false
    colors: [grey, green, red]
    hide_legend: false
    stacking: ''
    y_axis_tick_density: default
    point_style: none
    y_axis_tick_density_custom: 5
    x_axis_scale: auto
    y_axis_labels: [Unique Visitors, Day-over-Day Percent Change, (Negative)]
    x_axis_label: Visits by Hour, Past 4 Days
    y_axis_combined: false
    width: 16
    height: 8

  - name: add_a_unique_name_976
    title: Distribution of Sessions by Duration
    type: looker_column
    model: thelook
    explore: events
    dimensions: [session_facts.duration_seconds_tier]
    measures: [sessions.count]
    sorts: [session_facts.duration_seconds_tier]
    listen:
      visit_date: events.request_date
      country: countries.country_name
      browser: events.browser
    limit: 500
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_labels: [Number of Sessions]
    x_axis_gridlines: false
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_label_rotation: '-45'
    x_axis_label: Session Duration in Seconds
    show_value_labels: false
    show_view_names: true
    show_null_labels: false
    show_dropoff: false
    stacking: normal
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    x_axis_scale: auto
    width: 8
    height: 8

  - name: add_a_unique_name_867
    title: Visitors by Location
    type: looker_geo_choropleth
    model: thelook
    explore: events
    dimensions: [countries.country_code]
    measures: [events.unique_visitors]
    sorts: [events.unique_visitors desc]
    limit: 500
    listen:
      visit_date: events.request_date
      country: countries.country_name
      browser: events.browser
    map: world
    show_view_names: true
    quantize_colors: false
    colors: ['#ff0000']
    inner_border_color: '#ffffff'
    map_projection: ''
    loading: false
    width: 16
    height: 8  

  - name: add_a_unique_name_589
    title: Visitors in Top 20 Countries
    type: table
    explore: events
    dimensions: [countries.country_name]
    measures: [events.unique_visitors]
    listen:
      visit_date: events.request_date
      browser: events.browser
    filters:
      countries.country_name: -EMPTY
    sorts: [events.unique_visitors desc]
    limit: 20
    width: 8
    height: 8


  - name: add_a_unique_name_942
    title: Bounce Rate by Page (excluding login, logout)
    type: looker_column
    model: thelook
    explore: sessions
    dimensions: [events.2_level_url]
    measures: [events.bounce_rate, events.count]
    filters:
      events.2_level_url: -"/logout",-"/login",-EMPTY
      events.request_date: 7 days
    sorts: [events.count desc 0]
    limit: 10
    column_limit: ''
    stacking: ''
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    show_null_labels: false
    y_axis_orientation: [left, right]
    series_types:
      events.bounce_rate: line
    reference_lines: [{reference_type: line, line_value: median, range_start: max, range_end: min,
        margin_top: deviation, margin_value: mean, margin_bottom: deviation, label: Median BR%}]
    y_axis_min: ['.10']
    y_axis_combined: false
    label_density: 10
    series_labels:
      events.bounce_rate: Bounce Rate by Page
      events.count: Number of Page Views
    y_axis_combined: false
    width: 12
    height: 8

  - name: add_a_unique_name_613
    title: Bounce Rate by Page, Cohorted by Landing Page
    type: table
    model: thelook
    explore: sessions
    dimensions: [session_facts.landing_page_category, events.1_level_url]
    pivots: [events.1_level_url]
    measures: [events.bounce_rate]
    listen:
      visit_date: events.request_date
      browser: events.browser
    filters:
      events.full_page_url: -"/logout",-"/login"
    sorts: [events.bounce_rate desc 0]
    limit: 20
    height: 8
    width: 12



  - name: add_a_unique_name_329
    title: eCommerce Funnel
    type: looker_column
    model: thelook
    explore: sessions
    listen:
      visit_date: sessions.start_date
      country: countries.country_name
      browser: events.browser
    measures: [sessions.all_session, sessions.count_with_browse, sessions.count_with_add_to_cart,
      sessions.count_with_checkout]
    sorts: [sessions.all_session desc]
    limit: 500
    y_axis_gridlines: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_combined: true
    show_dropoff: true
    show_value_labels: false
    show_view_names: false
    show_null_labels: false
    x_axis_gridlines: false
    show_x_axis_label: true
    show_x_axis_ticks: true
    colors: ['#3a6f7f', '#4e94a9', '#62bad4', '#81c7dc', '#a0d5e5']
    stacking: ''
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    x_axis_scale: auto
    width: 12
    height: 8

  - name: add_a_unique_name_144
    title: Conversion Rate by Landing Page
    type: looker_column
    model: thelook
    explore: events
    dimensions: [session_facts.landing_page_category]
    measures: [sessions.cart_to_checkout_conversion]
    listen:
      visit_date: sessions.start_date
      country: countries.country_name
      browser: events.browser
    filters:
      sessions.cart_to_checkout_conversion: NOT NULL
    sorts: [sessions.cart_to_checkout_conversion desc]
    limit: 10
    stacking: ''
    show_value_labels: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    show_null_labels: false
    hidden_series: [sessions.count]
    width: 12
    height: 8



  - name: add_a_unique_name_996
    title: Most Viewed Brands
    type: looker_column
    model: thelook
    explore: events
    dimensions: [products.brand]
    measures: [events.count]
    listen:
      visit_date: events.request_date
      country: countries.country_name
      browser: events.browser
    filters:
      products.brand: -NULL
    sorts: [events.count desc]
    limit: 15
    show_value_labels: false
    show_view_names: true
    show_null_labels: false
    stacking: ''
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_combined: true
    series_labels:
      events.count: Total Pageviews
    x_axis_label_rotation: '-45'
    y_axis_labels: [Total Pageviews]
    x_axis_label: Brand Name
    width: 12
    height: 8
    
  - name: add_a_unique_name_762
    title: Top Brands - Pageviews, Uniques, Session Duration
    type: table
    model: thelook
    explore: events
    dimensions: [products.brand]
    measures: [events.count, events.unique_visitors, session_facts.average_duration]
    listen:
      visit_date: events.request_date
      country: countries.country_name
      browser: events.browser
    filters:
      products.brand: -NULL
    sorts: [events.count desc]
    limit: 15
    width: 12
    height: 8





# #----------------------------
# - dashboard: 2_brand_overview
# #----------------------------
#   title: "Brand Analytics, Web & Transactional"
#   layout: tile
#   tile_size: 50
#   
#   filters:
#   
#   - name: brand
#     title: "Brand Name"
#     type: field_filter
#     explore: order_items
#     field: products.brand
#     default_value: Calvin Klein
#     
#   - name: date
#     title: "Date"
#     type: date_filter
#     default_value: Last 90 Days
#     
#   elements:
#   
#   - name: total_orders
#     type: single_value
#     explore: order_items
#     measures: [orders.count]
#     listen:
#       date: orders.created_date
#       brand: products.brand
#     width: 8
#     height: 3
#     font_size: small
#     
#   - name: total_customers
#     type: single_value
#     explore: order_items
#     measures: [users.count]
#     listen:
#       date: orders.created_date
#       brand: products.brand
#     width: 8
#     height: 3
#     font_size: small
#     
#   - name: average_order_value
#     type: single_value
#     explore: order_items
#     measures: [order_items.average_sale_price]
#     listen:
#       date: orders.created_date
#       brand: products.brand
#     width: 8
#     height: 3
#     font_size: small
# 
# 
#   - name: add_a_unique_name_272
#     title: Brand Traffic by Source, OS
#     type: looker_donut_multiples
#     model: thelook
#     explore: events
#     dimensions: [users.traffic_source, events.os]
#     pivots: [users.traffic_source]
#     measures: [events.count]
#     listen:
#       date: events.request_date
#       brand: products.brand
#     filters:
#       events.os: '"Windows","Mac OS X","Linux (other)"'
# #       events.request_date: 90 days
#       users.traffic_source: -NULL
#     sorts: [events.count desc 1]
#     limit: 20
#     show_view_names: true
#     stacking: ''
#     show_value_labels: false
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     x_axis_scale: auto
#     show_null_labels: false
#     width: 12
#     height: 6
# 
#   - name: add_a_unique_name_359
#     title: Website Sessions by Transactional LTV
#     type: looker_area
#     model: thelook
#     explore: events
#     dimensions: [users_orders_facts.lifetime_number_of_orders_tier, sessions.start_hour]
#     pivots: [users_orders_facts.lifetime_number_of_orders_tier]
#     measures: [sessions.count]
#     listen:
#       brand: products.brand
#     filters:
#       sessions.start_date: 14 days
#     sorts: [sessions.start_hour]
#     limit: 500
#     show_view_names: true
#     stacking: normal
#     show_value_labels: false
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     x_axis_scale: auto
#     show_null_labels: false
#     show_null_points: true
#     series_labels:
#       1: 1 Lifetime Purchase
#       Undefined: Never Purchased
#     point_style: none
#     width: 12
#     height: 6
#     interpolation: linear
# 
#   - name: add_a_unique_name_349
#     title: Top Product Categories - Cart vs Conversion
#     type: looker_column
#     model: thelook
#     explore: events
#     dimensions: [products.category]
#     measures: [sessions.cart_to_checkout_conversion, sessions.count_with_add_to_cart]
#     listen:
#       date: events.request_date
#       brand: products.brand 
#     sorts: [sessions.count_with_add_to_cart desc]
#     limit: 8
#     y_axis_gridlines: false
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_combined: false
#     y_axis_orientation: [right, left]
#     show_value_labels: true
#     show_view_names: false
#     show_null_labels: false
#     colors: [black, '#62bad4']
#     stacking: ''
#     x_axis_gridlines: false
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     x_axis_label_rotation: -45
#     show_x_axis_ticks: true
#     x_axis_scale: auto
#     width: 12
#     height: 12
#     series_types:
#       sessions.cart_to_checkout_conversion: line
#     label_rotation: 0
# 
#   - name: add_a_unique_name_573
#     title: Top Visitors and Transcation History
#     type: table
#     model: thelook
#     explore: events
#     dimensions: [users.name, users.history, users.state, users.traffic_source]
#     measures: [sessions.count]
#     listen:
#       date: events.request_date
#       brand: products.brand
#     filters:
#       users.name: -NULL
#     sorts: [sessions.count desc]
#     limit: 50
#     width: 12
#     height: 12
#     
#   - name: sales_over_time
#     title: "Sales and Sale Price Trend"
#     type: looker_line
#     explore: order_items
#     dimensions: [orders.created_date]
#     measures: [order_items.total_sale_price, order_items.average_sale_price]
#     listen:
#       brand: products.brand
#       date: orders.created_date
#     limit: 500
#     width: 24
#     height: 6
#     legend_align:
#     stacking:
#     x_axis_label:
#     x_axis_datetime: yes
#     x_axis_datetime_label:
#     x_axis_label_rotation:
#     y_axis_orientation: [left,right]
# #     colors: [purple, gold]
#     y_axis_combined: false
#     y_axis_labels: ["Total Sale Amount","Average Selling Price"]
#     y_axis_min:
#     y_axis_max:
#     hide_points: yes
#     hide_legend: yes
#   
#   - name: sales_by_department_and_category
#     title: "Sales by Department and Category"
#     type: table
#     explore: order_items
#     dimensions: [products.category]
#     pivots: [products.department]
#     measures: [order_items.count, order_items.total_sale_price]
#     listen:
#       date: orders.created_date
#       brand: products.brand
#     sorts: [order_items.count desc]
#     limit: 500
#     width: 12
#     height: 8
#     
#   - name: connoisseur
#     title: "Top Purchasers of "
#     type: table
#     explore: order_items
#     dimensions: [users.name, users.email, users.history]
#     measures: [order_items.count, order_items.total_sale_price]
#     listen:
#       date: orders.created_date
#       brand: products.brand
#     sorts: [order_items.count desc]
#     limit: 15
#     width: 12
#     height: 8

 



