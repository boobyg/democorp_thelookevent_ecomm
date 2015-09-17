#----------------------------
- dashboard: 1_business_pulse
#----------------------------
  title: "1) Business Pulse"
  layout: grid
  rows:
    - elements: [total_orders, average_order_profit, first_purchasers]
      height: 220
    - elements: [orders_by_day_and_category, sales_by_date]
      height: 400
    - elements: [top_zips_map, sales_state_map]
      height: 400
    - elements: [sales_by_date_and_category, top_10_brands]
      height: 400
    - elements: [layer_cake_cohort]
      height: 400
    - elements: [customer_cohort]
      height: 400

  filters:

  - name: date
    title: "Date"
    type: date_filter
    default_value: Last 90 Days

  - name: state
    title: 'State / Region'
    type: field_filter
    explore: order_items
    field: users.state


  elements:

  - name: total_orders
    type: single_value
    explore: order_items
    measures: [orders.count]
    listen:
      date: orders.created_date
      state: users.state

  - name: average_order_profit
    type: single_value
    explore: order_items
    measures: [orders.average_profit]
    listen:
      date: orders.created_date
      state: users.state

  - name: first_purchasers
    type: single_value
    explore: order_items
    measures: [orders.first_purchase_count]
    listen:
      date: orders.created_date
      state: users.state

  - name: orders_by_day_and_category
    title: "Orders by Day and Category"
    type: looker_area
    explore: order_items
    dimensions: [orders.created_date]
    pivots: [products.category]
    measures: [order_items.count]
    filters:
      products.category: Blazers & Jackets, Sweaters, Pants, Shorts, Fashion Hoodies & Sweatshirts, Accessories
    listen:
      date: orders.created_date
      state: users.state
    sorts: [orders.created_date]
    limit: 500
    colors: ["#651F81", "#80237D", "#C488DD", "#Ef7F0F", "#FEAC47", "#8ED1ED"]
    legend_align:
    y_axis_labels: "# Order Items"
    stacking: normal
    x_axis_datetime: yes
    hide_points: yes
    hide_legend: yes
    x_axis_datetime_tick_count: 4
    show_x_axis_label: false

  - name: sales_by_date
    title: "Sales by Date"
    type: looker_column
    explore: order_items
    dimensions: [orders.created_date]
    measures: [order_items.total_sale_price]
    listen:
      state: users.state
      date: orders.created_date
    sorts: [orders.created_date]
    limit: 30
    colors: ["#651F81"]
    reference_lines:
      - value: [max, mean]
        label: Above Average
        color: "#Ef7F0F"
      - value: 20000
        label: Target
        color: "#Ef7F0F"
      - value: [median]
        label: Median
        color: "#Ef7F0F"
    x_axis_scale: time
    x_axis_datetime_tick_count: 4
    y_axis_labels: "Total Sale Price ($)"
    y_axis_combined: yes
    show_x_axis_label: false
    hide_legend: yes
    hide_points: yes

  - name: top_zips_map
    title: "Top Zip Codes"
    type: looker_geo_coordinates
    map: usa
    explore: order_items
    dimensions: [users.zip]
    measures: [order_items.count]
    colors: [gold, orange, darkorange, orangered, red]
    listen:
      date: orders.created_date
      state: users.state
    point_color: "#651F81"
    point_radius: 3
    sorts: [order_items.count desc]
    limit: 500

  - name: sales_state_map
    title: "Sales by State"
    type: looker_geo_choropleth
    map: usa
    explore: order_items
    dimensions: [users.state]
    measures: [order_items.count]
    colors: "#651F81"
    sorts: [order_items.total_sale_price desc]
    listen:
      date: orders.created_date
      state: users.state
    limit: 500

  - name: sales_by_date_and_category
    title: "Sales by Date and Category (Last 6 Weeks)"
    type: looker_donut_multiples
    explore: order_items
    dimensions: [orders.created_week]
    pivots: [products.category]
    measures: [order_items.count]
    filters:
      orders.created_date: 6 weeks ago for 6 weeks
      products.category: Accessories, Active, Blazers & Jackets, Clothing Sets
    sorts: [orders.created_week desc]
    colors: ["#651F81","#EF7F0F","#555E61","#2DA7CE"]
    limit: 24
    charts_across: 3

  - name: top_10_brands
    title: "Top 15 Brands"
    type: table
    explore: order_items
    dimensions: [products.brand]
    measures: [order_items.count, order_items.total_sale_price, order_items.average_sale_price]
    listen:
      date: orders.created_date
      state: users.state
    sorts: [order_items.count desc]
    limit: 15

  - name: layer_cake_cohort
    title: "Cohort - Orders Layered by Sign Up Month"
    type: looker_area
    explore: order_items
    dimensions: [orders.created_month]
    pivots: [users.created_month]
    measures: [orders.count]
    filters:
      orders.created_month: 12 months ago for 12 months
      users.created_month: 12 months ago for 12 months
    sorts: [orders.created_month]
    limit: 500
    y_axis_labels: ["Number of orders"]
    x_axis_label: "Order Month"
    legend_align: right
    colors: ["#FF0000","#DE0000","#C90000","#9C0202","#800101","#6B0000","#4D006B","#0D0080","#080054","#040029","#000000"]
    stacking: normal
    hide_points: yes

  - name: customer_cohort
    type: table
    explore: order_items
    dimensions: [users.created_month]
    pivots: [orders.created_month]
    measures: [users.count]
    filters:
      orders.created_month: 12 months ago for 12 months
      users.created_month: 12 months ago for 12 months
    sorts: [users.created_month]
    limit: 500

#----------------------------
- dashboard: 2_brand_overview
#----------------------------
  title: "2) Brand Overview"
  layout: grid
  show_applied_filters: false
  rows:
    - elements: [total_orders, total_customers, average_order_value]
      height: 180
    - elements: [sales_over_time]
      height: 300
    - elements: [sales_by_department_and_category, connoisseur]
      height: 400

  filters:



  - name: brand
    title: 'Brand Name'
    type: field_filter
    explore: order_items
    field: products.brand
    default_value: Calvin Klein


  - name: date
    title: "Date"
    type: date_filter
    default_value: Last 90 Days

  elements:

  - name: total_orders
    type: single_value
    explore: order_items
    measures: [orders.count]
    listen:
      date: orders.created_date
      brand: products.brand

  - name: total_customers
    type: single_value
    explore: order_items
    measures: [users.count]
    listen:
      date: orders.created_date
      brand: products.brand

  - name: average_order_value
    type: single_value
    explore: order_items
    measures: [order_items.average_sale_price]
    listen:
      date: orders.created_date
      brand: products.brand

  - name: sales_over_time
    title: Sales
    type: looker_line
    explore: order_items
    dimensions: [orders.created_date]
    measures: [order_items.total_sale_price, order_items.average_sale_price]
    listen:
      brand: products.brand
    filters:
      orders.created_date: 90 days
    limit: 500
    x_axis_datetime: yes
    hide_points: yes
    show_view_names: false
    y_axis_combined: true
    show_x_axis_label: false
    series_labels: 
      order_items.total_sale_price: Total Sales
      order_items.average_sale_price: Average Sale Price
    series_colors: 
      order_items.total_sale_price: purple
      order_items.average_sale_price: orange

  - name: sales_by_department_and_category
    title: "Sales by Department and Category"
    type: table
    explore: order_items
    dimensions: [products.category]
    pivots: [products.department]
    measures: [order_items.count, order_items.total_sale_price]
    listen:
      date: orders.created_date
      brand: products.brand
    sorts: [order_items.count desc]
    limit: 500

  - name: connoisseur
    title: Top Purchasers
    type: table
    explore: order_items
    dimensions: [users.name, users.email, users.history]
    measures: [order_items.count, order_items.total_sale_price]
    listen:
      date: orders.created_date
      brand: products.brand
    sorts: [order_items.count desc]
    limit: 15

#-----------------------------
- dashboard: 3_category_lookup
#-----------------------------
  title: "3) Category Lookup"
  layout: grid
  rows: 
    - elements: [total_orders, total_customers, average_order_value]
      height: 180
    - elements: [comparison, sales_by_day]
      height: 400
    - elements: [demographic, top_brands_within_category]
      height: 400

  filters:

  - name: category
    title: 'Category Name'
    type: field_filter
    explore: order_items
    field: products.category
    default_value: Jeans

  - name: department
    title: 'Department'
    type: field_filter
    explore: order_items
    field: products.department
    


  - name: date
    title: "Date"
    type: date_filter
    default_value: Last 90 Days

  elements:

  - name: total_orders
    type: single_value
    explore: order_items
    measures: [orders.count]
    listen:
      category: products.category
      date: orders.created_date
      department: products.department

  - name: total_customers
    type: single_value
    explore: order_items
    measures: [users.count]
    listen:
      date: orders.created_date
      category: products.category
      department: products.department

  - name: average_order_value
    type: single_value
    explore: order_items
    measures: [order_items.average_sale_price]
    listen:
      date: orders.created_date
      category: products.category
      department: products.department

  - name: comparison
    title: "All Categories Comparison"
    type: table
    explore: order_items
    dimensions: [products.category]
    measures: [order_items.average_sale_price, users.count, orders.count]
    listen:
      date: orders.created_date
      department: products.department
    sorts: [order_items.average_sale_price desc]
    limit: 50

  - name: sales_by_day
    title: "Sales by Date"
    type: looker_line
    explore: order_items
    dimensions: [orders.created_date]
    measures: [order_items.average_sale_price, order_items.total_sale_price]
    listen:
      date: orders.created_date
      category: products.category
      department: products.department
    sorts: [orders.created_date]
    x_axis_datetime: yes
    y_axis_orientation: [left,right]
    y_axis_labels: ["Average Selling Price ($)","Total Sale Amount ($)"]
    hide_points: yes

  - name: demographic
    title: "Age Demographic"
    type: looker_column
    explore: order_items
    dimensions: [users.age_tier]
    measures: [order_items.average_sale_price, order_items.count]
    listen:
      date: orders.created_date
      category: products.category
      department: products.department
    sorts: [users.age_tier]
    limit: 500
    x_axis_label: "Age Tier"
    y_axis_orientation: [left,right]
    y_axis_labels: ["Average Selling Price ($)","# orders"]

  - name: top_brands_within_category
    title: "Top Brands"
    type: table
    explore: order_items
    dimensions: [products.brand]
    measures: [order_items.count, order_items.total_sale_price]
    listen:
      date: orders.created_date
      category: products.category
      department: products.department
    sorts: [order_items.total_sale_price desc]
    limit: 25

#-------------------------
- dashboard: 4_user_lookup
#-------------------------
  title: "4) User Lookup"
  show_applied_filters: false
  layout: grid
  rows:
    - elements: [lifetime_orders, total_items_returned, lifetime_spend]
      height: 180
    - elements: [user_info, item_order_history, favorite_categories]
      height: 400
  
  filters:
  
  - name: email
    title: 'Email'
    type: field_filter
    explore: order_items
    field: users.email
  
  elements:   
  
  - name: user_info
    title: "User Info" 
    type: looker_single_record
    explore: order_items
    dimensions: [users.id, users.email, users.name, users.created_month, users.age,
      users.state, users.city, users.zip, users.history]
    listen:
      email: users.email
    filters:
      orders.created_date: 99 years      
    limit: 500
    show_null_labels: false
      
  - name: lifetime_orders
    title: "Lifetime Orders" 
    type: single_value
    explore: order_items
    measures: [orders.count]
    listen:
      email: users.email
    filters:
      orders.created_date: 99 years      
    sorts: [orders.count desc]
    limit: 500
    show_null_labels: false

  - name: total_items_returned
    title: "Total Items Returned"
    type: single_value
    explore: order_items
    measures: [order_items.count]
    filters:
    listen:
      email: users.email    
    filters:
      orders.created_date: 99 years      
    sorts: [order_items.count desc]
    limit: 500
    show_null_labels: false

  - name: lifetime_spend
    title: "Lifetime Spend" 
    type: single_value
    explore: order_items
    measures: [order_items.total_sale_price]
    listen:
      email: users.email
    filters:
      orders.created_date: 99 years      
    sorts: [order_items.total_sale_price desc]
    limit: 500
    show_null_labels: false

  - name: item_order_history
    title: "Items Order History" 
    type: table
    explore: order_items
    dimensions: [products.item_name]
    listen:
      email: users.email
    filters:
      orders.created_date: 99 years      
    sorts: [products.item_name]
    limit: 500

  - name: favorite_categories
    title: "Favorite Categories" 
    type: looker_pie
    explore: order_items
    dimensions: [products.category]
    measures: [order_items.count]
    listen:
      email: users.email
    filters:
      orders.created_date: 99 years
    sorts: [order_items.count desc]
    limit: 500
    

