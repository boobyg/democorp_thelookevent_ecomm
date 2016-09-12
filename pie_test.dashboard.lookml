- dashboard: pie_test
  title: Pie Test
  layout: tile
  tile_size: 100

#  filters:

  elements:

  - name: add_a_unique_name_1473700454
    title: Untitled Visualization
    type: looker_pie
    model: thelook
    explore: sessions
    dimensions: [sessions.includes_purchase]
    measures: [sessions.count]
    filters:
      sessions.session_start_date: 7 days
    sorts: [sessions.all_sessions desc, sessions.includes_purchase]
    limit: '500'
    column_limit: '50'
    query_timezone: America/Los_Angeles
    show_view_names: true
    colors: 'palette: Default'
    show_row_numbers: true
    ordering: none
    show_null_labels: false
    value_labels: legend
    label_type: labPer
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
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: ordinal
    point_style: circle_outline
    interpolation: linear
    discontinuous_nulls: false
    show_null_points: true
    series_types:
      users.count: column
    inner_radius: 50
    series_labels:
      'No': No Purchase
      'Yes': Results in Purchase
