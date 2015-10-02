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

#   - name: add_a_unique_name_218
#     title: Geolocation of visits
#     type: looker_geo_choropleth
#     base_view: log
#     dimensions: [countries.country_code]
#     measures: [log.request_count]
#     filters:
#       countries.country_code_3_letter: -NULL
#     listen:
#       days: log.request_date
#       country: countries.country_name
#     sorts: [log.request_count desc]
#     limit: 500
#     quantize_colors: false
#     show_null_labels: false
#     map: world
#     map_projection: cylindricalStereographic
#     show_antarctica: false
#     colors: ['#ff0000']
#     inner_border_color: '#ffffff'
#     loading: false
#     width: 16
#     height: 8

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
# 
#   - name: add_a_unique_name_816
#     title: Bounce Rate by Page (excluding login, logout)
#     type: looker_column
#     model: thelook
#     explore: sessions
#     dimensions: [events.2_level_url]
#     measures: [events.bounce_rate, events.count]
#     listen:
#       visit_date: events.request_date
#       browser: events.browser
#     filters:
#       events.full_page_url: -"/logout",-"/login"
#     sorts: [events.count desc 0]
#     limit: 10
#     stacking: ''
#     show_value_labels: false
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_view_names: true
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     x_axis_scale: auto
#     show_null_labels: false
#     y_axis_orientation: [left, right]
#     series_types:
#       events.bounce_rate: line
#     reference_lines: [{reference_type: line, line_value: median, range_start: max, range_end: min,
#         margin_top: deviation, margin_value: mean, margin_bottom: deviation, label: Median BR%}]
#     width: 12
#     y_axis_min: ['.05']
#     height: 8


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

#   - name: add_a_unique_name_187
#     title: eCommerce Funnel
#     type: looker_column
#     model: thelook
#     explore: events
#     measures: [events.unique_visitors, events.browse_visitors,
#       events.add_to_cart_visitors, events.login_visitors,
#       events.checkout_visitors]
#     listen:
#       visit_date: events.request_date
#       country: countries.country_name
#       browser: events.browser
#     sorts: [events.unique_visitors desc]
#     limit: 500
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_gridlines: true
#     y_axis_combined: true
#     show_value_labels: false
#     show_view_names: false
#     show_dropoff: true
#     show_null_labels: false
#     show_null_points: true
#     stacking: ''
#     x_axis_gridlines: false
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     x_axis_scale: auto
#     colors: ['#3a6f7f', '#4e94a9', '#62bad4', '#81c7dc', '#a0d5e5']
#     width: 16
#     height: 8



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


# 
# 
#   - name: add_a_unique_name_854
#     title: Top Pages Viewed
#     type: looker_bar
#     model: thelook
#     explore: events
#     dimensions: [events.full_page_url]
#     measures: [events.count]
#     listen:
#       visit_date: events.request_date
#     filters:
#       events.request_date: 14 days
#     sorts: [events.count desc]
#     limit: 10
#     show_value_labels: false
#     show_view_names: true
#     show_null_labels: false
#     stacking: ''
#     x_axis_gridlines: false
#     y_axis_gridlines: true
#     show_y_axis_labels: true
#     show_y_axis_ticks: true
#     y_axis_tick_density: default
#     y_axis_tick_density_custom: 5
#     show_x_axis_label: true
#     show_x_axis_ticks: true
#     x_axis_scale: auto
#     width: 16
#     height: 6





# 
#   - name: add_a_unique_name_801
#     title: Visits by Browser
#     type: looker_pie
#     explore: events
#     listen:
#       visit_date: events.request_date
#       country: countries.country_name
#     dimensions: [events.browser]
#     measures: [events.unique_visitors]
#     sorts: [events.unique_visitors desc]
#     limit: 50
#     show_null_labels: false
# #     colors: ['#651F81', '#C488DD', '#FEAC47', '#8ED1ED']
#     width: 8
#     height: 8


 



