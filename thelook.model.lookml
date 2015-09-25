- connection: thelook_redshift
- persist_for: 1 hour            # cache all query results for one hour
- template: liquid
- label: eCommerce with Event Data

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards


########################################
############## Base Explore ############
########################################

- explore: order_items
  view: order_items
  label: '(1) Orders, Items and Users'
  joins:
    - join: orders
      relationship: many_to_one
      sql_on: ${orders.id} = ${order_items.order_id}
    
    - join: order_facts
      view_label: 'Orders'
      relationship: many_to_one
      sql_on: ${order_facts.order_id} = ${order_items.order_id}

    - join: inventory_items
      type: full_outer             #Left Join only brings in items that have been sold as order_item
      relationship: one_to_many    
      sql_on: ${inventory_items.id} = ${order_items.inventory_item_id}

    - join: users
      relationship: many_to_one
      sql_on: ${orders.user_id} = ${users.id} 
    
    - join: user_order_facts
      view_label: 'Users'
      relationship: many_to_one
      sql_on: ${user_order_facts.user_id} = ${orders.user_id}

    - join: products
      relationship: many_to_one
      sql_on: ${products.id} = ${inventory_items.product_id}
      
    - join: subsequent_order_facts
      relationship: many_to_one
      type: full_outer
      sql_on: ${orders.id} = ${subsequent_order_facts.order_id}



########################################
#########  Advanced Extensions #########
########################################



- explore: affinity
  label: '(2) Affinity Analysis'
  always_filter: 
    affinity.product_b_id: '-NULL'
  joins:
    - join: product_a
      from: products
      view_label: 'Product A Details'
      relationship: many_to_one
      sql_on: ${affinity.product_a_id} = ${product_a.id}
      
    - join: product_b
      from: products
      view_label: 'Product B Details'
      relationship: many_to_one
      sql_on: ${affinity.product_b_id} = ${product_b.id}  

      
- explore: orders_share_of_wallet
  label: '(3) Share of Wallet Analysis'
  hidden: false
  extends: orders
  joins:
  - join: product_selected
    type: cross
    relationship: one_to_one
  
  - join: order_items
    from: order_items_share_of_wallet
    
- explore: monthly_activity
  label: '(4) Cohort Retention Analysis and LTV'
  joins:
  - join: users
    sql_on: ${users.id} = ${monthly_activity.user_id}
    relationship: many_to_one
    
  - join: user_order_facts
    view_label: 'Users'
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${users.id}
    

- explore: journey_mapping
  label: '(5) Customer Journey Mapping'
  extends: order_items
  joins:
    - join: next_order
      from: orders
      sql_on: ${subsequent_order_facts.next_order_id} = ${next_order.id}
      relationship: many_to_one
      
    - join: next_order_items
      from: order_items
      sql_on: ${next_order.id} = ${next_order_items.order_id}
      relationship: one_to_many
      
    - join: next_order_inventory_items
      from: inventory_items
      relationship: many_to_one
      sql_on: ${next_order_items.inventory_item_id} = ${inventory_items.id}
    
    - join: next_order_products
      from: products
      relationship: many_to_one
      sql_on: ${next_order_inventory_items.product_id} = ${next_order_products.id}



########################################
#########  Other Dependencies ##########
########################################

      
- explore: orders
  hidden: true
  view: orders
  joins:
    - join: order_items
      relationship: one_to_many
      sql_on: ${order_items.order_id} = ${orders.id}
      
    - join: users
      relationship: many_to_one
      type: left_outer
      sql_on: ${orders.user_id} = ${users.id}
      
    - join: inventory_items
      relationship: many_to_one
      type: left_outer
      sql_on: ${order_items.inventory_item_id} = ${inventory_items.id}

    - join: products
      relationship: many_to_one
      type: left_outer
      sql_on: ${inventory_items.product_id} = ${products.id}  
      
    - join: order_facts
      view_label: 'Orders'
      relationship: many_to_one
      sql_on: ${order_facts.order_id} = ${order_items.order_id}  
