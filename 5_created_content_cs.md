<div style="width: 100%; text-align: center; overflow: hidden;">

<h1 style="background-color: #fff; padding: 30px 0 15px;font-weight:500; text-transform: uppercase; margin-bottom: 0; font-weight: 600;">CUSTOMER SUCCESS APP</h1>

<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <h5 style="float: left; padding: 15px 25px; background-color: #eb8b33; border-radius: 5px; width: 240px; margin: 10px 15px 20px 0; text-align: center;"><a target="_blank" style="color: #fff; text-transform: uppercase;" href="https://demonew.looker.com/dashboards/289?Account%20Executive%20Name=&date=&filter_config=%7B%22Account%20Executive%20Name%22:%5B%7B%22type%22:%22%3D%22,%22values%22:%5B%7B%22constant%22:%22%22%7D,%7B%7D%5D,%22id%22:4%7D%5D,%22date%22:%5B%7B%22type%22:%22advanced%22,%22values%22:%5B%7B%22constant%22:null%7D,%7B%7D%5D,%22id%22:5%7D%5D%7D">Customer Overview Dashboard</a></h5>
  <div style="text-align: left; font-size: 17px;">
    <p style="font-weight: 300; margin-top: 17px;">Tracks customer health and growth at a high level. Tracks MRR and growth overtime in conjucntion with customer health scores. We can also see DAUs compared with MAUs. This dashboard can serve as a jumping off point for understanding cusomter health and usage. The Looks can be edited to query any customer attributes.  </p>
  </div>
</div>

<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <h5 style="float: left; padding: 15px 25px; background-color: #eb8b33; border-radius: 5px; width: 240px; margin: 10px 15px 20px 0; text-align: center;"><a target="_blank" style="color: #fff; text-transform: uppercase;" href="https://demonew.looker.com/explore/salesforce/the_switchboard">The Switchboard</a></h5>
  <div style="text-align: left; font-size: 17px;">
    <p style="font-weight: 300; margin-top: 10px;">Exploring the swtichboard creates a unified view of our salesforce data. This will allow you to answer questions regarding all the different salesforce attributes like leads, opportunities, and accounts.  </p>
  </div>
</div>
<div style=" float: left; margin-bottom: 15px; width: 100%;">
<look name = "e3">
  type: looker_line
  model: salesforce
  explore: the_switchboard
  dimensions: [opportunity.closed_month]
  measures: [opportunity.net_expansion, opportunity.total_expansion_acv, opportunity.churn_acv]
  filters:
    opportunity.closed_week: 13 months
    opportunity.lost_reason: NULL,Non-renewal
    opportunity.type: Renewal,Addon/Upsell,NULL
  sorts: [opportunity.closed_month]
  limit: '500'
  column_limit: '50'
  query_timezone: America/Los_Angeles
  colors: [black, '#49cec1', '#dc7350']
  stacking: ''
  show_value_labels: true
  label_density: 25
  legend_position: center
  x_axis_gridlines: true
  y_axis_gridlines: true
  show_view_names: false
  y_axis_combined: true
  show_y_axis_labels: false
  show_y_axis_ticks: true
  y_axis_tick_density: default
  y_axis_tick_density_custom: 5
  show_x_axis_label: false
  show_x_axis_ticks: true
  x_axis_scale: ordinal
  point_style: circle_outline
  interpolation: linear
  series_types:
    opportunity.total_expansion_acv: column
    opportunity.churn_acv: column
  ordering: none
  show_null_labels: false
  show_totals_labels: false
  show_silhouette: false
  totals_color: '#808080'
  label_color: [black, transparent, transparent]
  label_value_format: $#,##0
  font_size: 10px
  show_null_points: true
  swap_axes: false
  y_axis_labels: [Dollars]
  y_axis_value_format: $#,##0
  limit_displayed_rows: false
  y_axis_scale_mode: linear
</look>  
</div>  
  

<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <h5 style="float: left; padding: 15px 25px; background-color: #eb8b33; border-radius: 5px; width: 240px; margin: 10px 15px 20px 0; text-align: center;"><a target="_blank" style="color: #fff; text-transform: uppercase;" href="https://demonew.looker.com/explore/salesforce/rolling_30_day_activity_facts">Activity Facts</a></h5>
  <div style="text-align: left; font-size: 17px;">
    <p style="font-weight: 300; margin-top: 17px;">The 30 day activity fact explore can answer questions regarging number of DAUs.</p>
  </div>
</div>

<div style=" float: left; margin-bottom: 15px; width: 100%;">
<look name = "e4">

  type: looker_line
  model: salesforce
  explore: rolling_30_day_activity_facts
  dimensions: [rolling_30_day_activity_facts.date_date]
  measures: [rolling_30_day_activity_facts.user_count_active_this_day, rolling_30_day_activity_facts.user_count_active_30_days]
  dynamic_fields:
  - table_calculation: dau_mau_ratio
    label: DAU-MAU Ratio
    expression: ${rolling_30_day_activity_facts.user_count_active_this_day} / ${rolling_30_day_activity_facts.user_count_active_30_days}
    value_format:
    value_format_name: percent_2
  - table_calculation: 7_day_rolling_avg_dau_mau
    label: 7-Day Rolling Avg DAU-MAU
    expression: mean(offset_list(${dau_mau_ratio}, 0, 7))
    value_format:
    value_format_name: percent_0
  filters:
    rolling_30_day_activity_facts.date_date: 365 days
  sorts: [rolling_30_day_activity_facts.date_date desc]
  limit: '500'
  column_limit: '50'
  query_timezone: America/Los_Angeles
  colors: ['#5245ed', '#ed6168', '#1ea8df', '#353b49', '#49cec1', '#b3a0dd', '#db7f2a',
    '#706080', '#a2dcf3', '#776fdf', '#e9b404', '#635189']
  color_palette: Santa Cruz
  stacking: ''
  show_value_labels: false
  label_density: 14
  legend_position: center
  x_axis_gridlines: false
  y_axis_gridlines: true
  show_view_names: false
  limit_displayed_rows: false
  y_axis_combined: false
  show_y_axis_labels: true
  show_y_axis_ticks: true
  y_axis_tick_density: default
  y_axis_tick_density_custom: 5
  show_x_axis_label: true
  show_x_axis_ticks: true
  x_axis_scale: auto
  y_axis_scale_mode: linear
  show_null_points: true
  point_style: none
  interpolation: linear
  ordering: none
  show_null_labels: false
  show_totals_labels: false
  show_silhouette: false
  totals_color: '#808080'
  y_axis_value_format: ''
  hidden_fields: [rolling_30_day_activity_facts.user_count_active_this_day, dau_mau_ratio]
  x_axis_label: Date
  y_axis_labels: [User Count]
  y_axis_orientation: [left, right]



</look>  
</div>  
  


</div>

