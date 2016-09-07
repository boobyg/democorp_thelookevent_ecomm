<div style="width: 100%; text-align: center; overflow: hidden;">

<h1 style="background-color: #fff; padding: 30px 0 15px;font-weight:500; text-transform: uppercase; margin-bottom: 0; font-weight: 600;">SALES ANALYTICS APP</h1>

<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <h5 style="float: left; padding: 15px 25px; background-color: #eb8b33; border-radius: 5px; width: 240px; margin: 10px 15px 20px 0; text-align: center;"><a target="_blank" style="color: #fff; text-transform: uppercase;" href="https://demonew.looker.com/dashboards/317">All Sales Dashboard</a></h5>
  <div style="text-align: left; font-size: 17px;">
    <p style="font-weight: 300; margin-top: 17px;">This is were you'll find all of the core metrics we track for sales. Its automatically filtered to this quarter but feel free adjust for any time period you're interested in. This is mostly based off the QBR that Anicia and Jake's team has been prepairing for Tuesday Club but now its not static. In addition to changing the filters at the top you can rerun the entire dashoard or have it emailed to you whenever you want. Feel free  to drill into any of the aggregations or just kick on the cog next to the chart for options on how to modify that report.</p>
  </div>
</div>

<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <h5 style="float: left; padding: 15px 25px; background-color: #eb8b33; border-radius: 5px; width: 240px; margin: 10px 15px 20px 0; text-align: center;"><a target="_blank" style="color: #fff; text-transform: uppercase;" href="https://demonew.looker.com/x/4QzR3Jh">Sales Pipeline</a></h5>
  <div style="text-align: left; font-size: 17px;">
    <p style="font-weight: 300; margin-top: 10px;">The quarterly sales Pipeline reports on each reps opportunities into their respective stages. Try clicking on some opportunities that your interested in learning more about instead of bugging Arielle for more detail. </p>
  </div>
</div>

<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <look style="height:350;" name="e2">
    type: looker_bar
    model: salesforce
    explore: opportunity
    dimensions: [opportunity.stage_name_funnel, salesrep.name]
    pivots: [opportunity.stage_name_funnel]
    measures: [opportunity.total_acv]
    dynamic_fields:
    - table_calculation: total_pipeline
      label: Total Pipeline
      expression: |-
        sum(pivot_row(${opportunity.total_acv}))
  
        # This field was created to be used to sort the chart. Another reasonable sort value would be the sum of won and winning deals:
  
        #coalesce(pivot_offset(${opportunity.total_acv}, 1), 0) + coalesce(pivot_offset(${opportunity.total_acv}, 2), 0)
  
        #The "coalesce" function is used above to ensure that null values are evaluated to 0 instead of null (which breaks the calculation)
      value_format_name: usd_0
    filters:
      opportunity.closed_quarter: this quarter
      opportunity.stage_name_funnel: -Lost
      salesrep.name: -NULL
    sorts: [opportunity.stage_name_funnel desc, total_pipeline desc, opportunity.stage_name_funnel__sort_]
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
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: '#808080'
    colors:
    hidden_fields: [total_pipeline]
  
  </look>
</div>
<!--SECOND EXPLORE-->
<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <h5 style="float: left; padding: 15px 25px; background-color: #eb8b33; border-radius: 5px; width: 240px; margin: 10px 15px 20px 0; text-align: center;"><a target="_blank" style="color: #fff; text-transform: uppercase;" href="https://demonew.looker.com/x/DpMfJxY">At Risk Customers</a></h5>
  <div style="text-align: left; font-size: 17px;">
    <p style="font-weight: 300; margin-top: 17px;">Customers at risk are defined as cusomers with a health score < 10. If you are curious as to what negative characteristics each of these customers have click on the account name to look them up on the customer specific dashboard. Feel free to chat the link to customer success if you are worried about a specific account.</p>
  </div>
</div>

<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <look style="height:350;" name="e3">
  type: table
  model: salesforce
  explore: the_switchboard
  dimensions: [account.name, salesrep.name]
  measures: [opportunity.total_acv, opportunity_zendesk_facts.total_days_open]
  filters:
    opportunity.is_closed: 'No'
    salesrep.name: -NULL
    opportunity.total_acv: not 0
    opportunity.closed_quarter: this quarter
  sorts: [opportunity_zendesk_facts.health, salesrep.name desc]
  limit: '15'
  column_limit: '50'
  query_timezone: America/Los_Angeles
  show_view_names: false
  show_row_numbers: false
  stacking: ''
  show_value_labels: true
  label_density: 25
  x_axis_gridlines: false
  y_axis_gridlines: true
  show_y_axis_labels: true
  show_y_axis_ticks: true
  y_axis_tick_density: default
  y_axis_tick_density_custom: 5
  show_x_axis_label: false
  show_x_axis_ticks: true
  x_axis_scale: auto
  show_null_labels: false
  font_size: small
  colors: ['#a2dcf3']
  label_color: ['#1ea8df']
  hide_legend: false
  y_axis_labels: [Total ACV Pipeline]
  legend_position: center
  y_axis_combined: true
  ordering: none
  truncate_column_names: false
  table_theme: gray
  series_labels:
    opportunity.total_acv: ACV
    zendesk_ticket.count_tickets_before_close: Tickets
    opportunity_zendesk_facts.total_days_open: Opp Age
    account.name: Company
    salesrep.name: Rep
  limit_displayed_rows: false
 

  </looker>
</div>

<div style=" float: left; margin-bottom: 15px; width: 100%;">
  <h5 style="float: left; padding: 15px 25px; background-color: #eb8b33; border-radius: 5px; width: 240px; margin: 10px 15px 20px 0; text-align: center;"><a target="_blank" style="color: #fff; text-transform: uppercase;" href="http://www.looker.com/docs/exploring-data/building-dashboards">2nd Explore</a></h5>
  <div style="text-align: left; font-size: 17px;">
    <p style="font-weight: 300; margin-top: 17px;">Create entry points into the data with dashboards.</p>
  </div>
</div>

<!--THIRD EXPLORE-->
<!--  <div style=" float: left; margin-bottom: 15px; width: 100%;">-->
<!--    <look style="height:350;" name="e4">-->
<!--      type: table-->
<!--      model: salesforce-->
<!--      explore: the_switchboard-->
<!--      dimensions: [account.name, opportunity_zendesk_facts.health, salesrep.name]-->
      <!--measures: [opportunity.total_acv, opportunity_zendesk_facts.total_days_open]-->
<!--      filters:-->
<!--        opportunity.is_closed: 'No'-->
<!--        opportunity_zendesk_facts.health: <30-->
<!--        salesrep.name: -NULL-->
<!--        opportunity.total_acv: not 0-->
<!--        opportunity.closed_quarter: this quarter-->
<!--      sorts: [opportunity_zendesk_facts.health, salesrep.name desc]-->
<!--      limit: '15'-->
<!--      column_limit: '50'-->
<!--      query_timezone: America/Los_Angeles-->
<!--      show_view_names: false-->
<!--      show_row_numbers: false-->
<!--      stacking: ''-->
<!--      show_value_labels: true-->
<!--      label_density: 25-->
<!--      x_axis_gridlines: false-->
<!--      y_axis_gridlines: true-->
<!--      show_y_axis_labels: true-->
<!--      show_y_axis_ticks: true-->
<!--      y_axis_tick_density: default-->
<!--      y_axis_tick_density_custom: 5-->
<!--      show_x_axis_label: false-->
<!--      show_x_axis_ticks: true-->
<!--      x_axis_scale: auto-->
<!--      show_null_labels: false-->
<!--      font_size: small-->
<!--      colors: ['#a2dcf3']-->
<!--      label_color: ['#1ea8df']-->
<!--      hide_legend: false-->
<!--      y_axis_labels: [Total ACV Pipeline]-->
<!--      legend_position: center-->
<!--      y_axis_combined: true-->
<!--      ordering: none-->
<!--      truncate_column_names: false-->
<!--      table_theme: gray-->
<!--      series_labels:-->
<!--        opportunity.total_acv: ACV-->
<!--        zendesk_ticket.count_tickets_before_close: Tickets-->
<!--        opportunity_zendesk_facts.total_days_open: Opp Age-->
<!--        account.name: Company-->
<!--        salesrep.name: Rep-->
<!--      limit_displayed_rows: false-->
<!--    </look>-->
<!--  </div>-->
<!--</div>-->


