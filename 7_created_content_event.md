<div style="width: 100%; text-align: center; overflow: hidden;">

<h1 style="background-color: #fff; padding: 30px 0 15px;font-weight:500; text-transform: uppercase; margin-bottom: 0; font-weight: 600;">ECOMMERCE WITH WEB ANALYTICS</h1>

<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <h5 style="float: left; padding: 15px 25px; background-color: #eb8b33; border-radius: 5px; width: 240px; margin: 10px 15px 20px 0; text-align: center;"><a target="_blank" style="color: #fff; text-transform: uppercase;" href="/dashboards/159">Business Pulse Dashboard</a></h5>
  <div style="text-align: left; font-size: 17px;">
    <p style="font-weight: 300; margin-top: 17px;">Here is your monthly report! No need to wait for these from Jack every month, you can come see the data, in real time right here in your browser. Use the filters at the top to slice the data in different ways, and see more than you ever could before!</p>
  </div>
</div>

<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <h5 style="float: left; padding: 15px 25px; background-color: #eb8b33; border-radius: 5px; width: 240px; margin: 10px 15px 20px 0; text-align: center;"><a target="_blank" style="color: #fff; text-transform: uppercase;" href="http://www.looker.com/docs/exploring-data/visualizing-query-results">Explore your Users and their Orders</a></h5>
  <div style="text-align: left; font-size: 17px;">
    <p style="font-weight: 300; margin-top: 10px;">Do you have questions about your orders and the users making them? Click here to get information like the graph you see below! Learn more about your customer base, the products that they're ordering, and how much value you're gaining from them by using a simple drag-and-drop interface. No need to bother Jack for these reports every week. Make them yourself!</p>
  </div>
</div>

<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <look style="height:350;" name="demographics">
    type: looker_area
    model: thelook
    explore: order_items
    dimensions: [users.age_tier, users.gender]
    pivots: [users.gender]
    measures: [order_items.count]
    filters:
      order_items.created_date: 90 days
    sorts: [users.age_tier, users.gender]
    limit: '500'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    stacking: normal
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: true
    limit_displayed_rows: false
    y_axis_combined: true
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
    interpolation: monotone
    show_totals_labels: false
    show_silhouette: false
    totals_color: '#808080'
    series_types: {}
    colors: 'palette: Santa Cruz'
    series_colors: {}
  
  </look>
</div>

<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <h5 style="float: left; padding: 15px 25px; background-color: #eb8b33; border-radius: 5px; width: 240px; margin: 10px 15px 20px 0; text-align: center;"><a target="_blank" style="color: #fff; text-transform: uppercase;" href="http://www.looker.com/docs/exploring-data/building-dashboards">Explore Web Data</a></h5>
  <div style="text-align: left; font-size: 17px;">
    <p style="font-weight: 300; margin-top: 17px;">Find out about how your users are traversing your website. Ask questions about bounce rates, sessions lengths, conversion rates, funnels, and much more here. You can even related this data back to purchases to do comparisons across the board. No need to bother Jack for these reports every week. Make them yourself!</p>
  </div>
</div>

  <div style=" float: left; margin-bottom: 15px; width: 100%;">
    <look style="height:350;" name="Event Funnel">
      type: looker_column
      model: thelook
      explore: sessions
      measures: [sessions.all_sessions, sessions.count_browse_or_later, sessions.count_product_or_later,
        sessions.count_cart_or_later, sessions.count_purchase]
      filters:
        sessions.session_start_date: 7 days
      sorts: [sessions.all_sessions desc]
      limit: '500'
      column_limit: '50'
      query_timezone: America/Los_Angeles
      y_axis_gridlines: false
      show_y_axis_labels: true
      show_y_axis_ticks: true
      y_axis_combined: true
      show_value_labels: true
      show_view_names: false
      x_axis_gridlines: false
      show_x_axis_label: true
      show_x_axis_ticks: true
      colors:
      stacking: ''
      y_axis_tick_density: default
      y_axis_tick_density_custom: 5
      x_axis_scale: auto
      label_density: 25
      legend_position: center
      limit_displayed_rows: false
      y_axis_scale_mode: linear
      show_dropoff: true
      show_null_labels: false
      ordering: none
      show_totals_labels: false
      show_silhouette: false
      totals_color: '#808080'
      point_style: circle
      show_null_points: true
      interpolation: linear
    </look>

  </div>


</div>

