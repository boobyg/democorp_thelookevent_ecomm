- dashboard: shipping_logistics_and_operations
  title: Shipping Logistics & Operations
  layout: newspaper
  elements:
  - title: Order Shipment Status
    name: Order Shipment Status
    model: thelook_redshfit
    explore: order_items
    type: looker_column
    fields:
    - order_items.created_date
    - order_items.status
    - order_items.order_count
    pivots:
    - order_items.status
    filters:
      order_items.created_date: 60 days
      order_items.status: Complete,Shipped,Processing
    sorts:
    - order_items.created_date desc
    - order_items.status
    limit: 500
    column_limit: 50
    query_timezone: America/Los_Angeles
    show_view_names: false
    color_palette: Custom
    limit_displayed_rows: false
    stacking: normal
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: false
    show_x_axis_ticks: true
    x_axis_scale: auto
    ordering: none
    show_null_labels: false
    colors:
    - green
    - red
    - orange
    y_axis_scale_mode: linear
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    hidden_fields: []
    y_axes: []
    listen:
      Distribution Center: distribution_centers.name
    row: 0
    col: 0
    width: 12
    height: 7
  - title: Open Orders >3 Days Old - Immediate Action Required
    name: Open Orders >3 Days Old - Immediate Action Required
    model: thelook_redshfit
    explore: order_items
    type: table
    fields:
    - order_items.order_id
    - users.name
    - users.email
    - order_items.created_date
    - order_items.status
    - products.item_name
    filters:
      order_items.created_date: before 3 days ago
      order_items.status: '"Processing"'
    sorts:
    - order_items.created_date
    limit: 500
    column_limit: 50
    query_timezone: America/Los_Angeles
    show_view_names: false
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: transparent
    limit_displayed_rows: false
    hidden_fields: []
    y_axes: []
    listen:
      Distribution Center: distribution_centers.name
    row: 7
    col: 12
    width: 12
    height: 8
  - title: Open Orders - Where do we need to ship?
    name: Open Orders - Where do we need to ship?
    model: thelook_redshfit
    explore: order_items
    type: looker_map
    fields:
    - distribution_centers.location
    - users.approx_location
    - order_items.average_days_to_process
    filters:
      order_items.status: '"Processing"'
      order_items.order_count: ">0"
    sorts:
    - order_items.average_days_to_process desc
    limit: 500
    map_plot_mode: lines
    heatmap_gridlines: true
    map_tile_provider: positron
    map_position: custom
    map_scale_indicator: 'off'
    map_pannable: true
    map_zoomable: true
    map_marker_type: circle
    map_marker_icon_name: default
    map_marker_radius_mode: proportional_value
    map_marker_units: meters
    map_marker_proportional_scale_type: linear
    map_marker_color_mode: fixed
    show_view_names: true
    show_legend: true
    quantize_map_value_colors: false
    map_latitude: 36.31512514748051
    map_longitude: -92.10937499999999
    map_zoom: 3
    hidden_fields: []
    y_axes: []
    listen:
      Distribution Center: distribution_centers.name
    row: 15
    col: 12
    width: 12
    height: 8
  - title: Average Shipping Time to Users
    name: Average Shipping Time to Users
    model: thelook_redshfit
    explore: order_items
    type: looker_map
    fields:
    - users.approx_location
    - order_items.average_shipping_time
    filters:
      users.approx_location_bin_level: '7'
    sorts:
    - order_items.average_shipping_time desc
    limit: 5000
    map_plot_mode: automagic_heatmap
    heatmap_gridlines: true
    map_tile_provider: positron
    map_position: custom
    map_scale_indicator: 'off'
    map_pannable: true
    map_zoomable: true
    map_marker_type: circle
    map_marker_icon_name: default
    map_marker_radius_mode: proportional_value
    map_marker_units: meters
    map_marker_proportional_scale_type: linear
    map_marker_color_mode: fixed
    show_view_names: true
    show_legend: true
    quantize_map_value_colors: false
    map_latitude: 36.527294814546245
    map_longitude: -92.19726562500001
    map_zoom: 3
    hidden_fields: []
    y_axes: []
    listen:
      Distribution Center: distribution_centers.name
    row: 0
    col: 12
    width: 12
    height: 7
  - title: Most Common Shipping Locations
    name: Most Common Shipping Locations
    model: thelook_redshfit
    explore: order_items
    type: looker_map
    fields:
    - distribution_centers.location
    - users.approx_location
    - order_items.order_count
    filters:
      order_items.order_count: ">30"
    sorts:
    - order_items.created_date
    - order_items.order_id
    - order_items.order_count desc
    limit: 1000
    map_plot_mode: lines
    heatmap_gridlines: true
    map_tile_provider: positron
    map_position: custom
    map_scale_indicator: 'off'
    map_pannable: true
    map_zoomable: true
    map_marker_type: circle
    map_marker_icon_name: default
    map_marker_radius_mode: proportional_value
    map_marker_units: meters
    map_marker_proportional_scale_type: linear
    map_marker_color_mode: fixed
    show_view_names: true
    show_legend: true
    quantize_map_value_colors: false
    map_latitude: 43.58039085560786
    map_longitude: -61.52343749999999
    map_zoom: 3
    map_value_scale_clamp_max: 300
    map_value_scale_clamp_min: 30
    hidden_fields: []
    y_axes: []
    listen:
      Distribution Center: distribution_centers.name
    row: 15
    col: 0
    width: 12
    height: 8
  - title: Inventory Aging Report
    name: Inventory Aging Report
    model: thelook_redshfit
    explore: order_items
    type: looker_column
    fields:
    - inventory_items.days_in_inventory_tier
    - inventory_items.count
    filters:
      inventory_items.is_sold: 'No'
    sorts:
    - inventory_items.days_in_inventory_tier
    limit: 500
    column_limit: 50
    query_timezone: America/Los_Angeles
    stacking: normal
    show_value_labels: true
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    ordering: none
    show_null_labels: false
    colors:
    - grey
    limit_displayed_rows: false
    y_axis_scale_mode: linear
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_colors: {}
    hidden_fields: []
    y_axes: []
    listen:
      Distribution Center: distribution_centers.name
    note_state: collapsed
    note_display: below
    note_text: Unsold inventory only
    row: 7
    col: 0
    width: 12
    height: 8
  filters:
  - name: Distribution Center
    title: Distribution Center
    type: field_filter
    default_value: Chicago IL
    allow_multiple_values: true
    required: false
    model: thelook_redshfit
    explore: order_items
    listens_to_filters: []
    field: distribution_centers.name
