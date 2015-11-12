- connection: event
- persist_for: 1 hour            # cache all query results for one hour
- label: 'eCommerce with Event Data'
- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards


########################################
############## Base Explores ###########
########################################

- explore: order_items
  label: '(1) Orders, Items and Users'
  view: order_items
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
#########  Event Data Explores #########
########################################


- explore: events
  label: '(2) Web Event Data'
  joins:
    - join: sessions
      sql_on: ${events.session_id} =  ${sessions.session_id}
      relationship: many_to_one

    - join: session_facts
      sql_on: ${sessions.session_id} = ${session_facts.session_id}
      relationship: one_to_one
      view_label: 'Sessions'
      
    - join: classb
      sql_on: ${events.classb} = ${classb.classb}
      relationship: many_to_one

    - join: countries
      sql_on: ${classb.country} = ${countries.country_code_2_letter}
      relationship: many_to_one
      view_label: 'Visitors'

    - join: products
      sql_on: ${events.product_id} = ${products.id}
      relationship: many_to_one
      
    - join: inventory_items
      sql_on: ${products.id} =${inventory_items.product_id}
      relationship: one_to_many

    - join: users
      sql_on: ${events.user_id} = ${users.id}
      relationship: many_to_one

    - join: user_order_facts
      sql_on: ${users.id} = ${user_order_facts.user_id}
      relationship: one_to_one
      view_label: 'Users'    
      
      
- explore: sessions
  label: '(3) Web Session Data'
  joins: 
    - join: events
      sql_on: ${sessions.session_id} = ${events.session_id}
      relationship: one_to_many
      
    - join: classb
      relationship: many_to_one
      sql_on: ${events.classb} = ${classb.classb}
      
    - join: countries
      required_joins: classb
      relationship: many_to_one
      sql_on: ${classb.country} = ${countries.country_code_2_letter}
      view_label: 'Visitors'
      
    - join: session_facts
      relationship: many_to_one
      view_label: 'Sessions'
      sql_on: ${sessions.session_id} = ${session_facts.session_id}
    
    - join: products
      relationship: many_to_one
      sql_on: ${products.id} = ${events.product_id}
    
    - join: users
      relationship: many_to_one
      sql_on: ${users.id} = ${events.user_id}
    
    - join: user_order_facts
      relationship: many_to_one
      sql_on: ${user_order_facts.user_id} = ${users.id}
      view_label: 'Users' 

########################################
#########  Advanced Extensions #########
########################################



- explore: affinity
  label: '(4) Affinity Analysis'
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
  label: '(5) Share of Wallet Analysis'
  hidden: false
  extends: orders
  joins:
  - join: product_selected
    type: cross
    relationship: one_to_one
  
  - join: order_items
    from: order_items_share_of_wallet
    
- explore: monthly_activity
  label: '(6) Cohort Retention Analysis and LTV'
  joins:
  - join: users
    sql_on: ${users.id} = ${monthly_activity.user_id}
    relationship: many_to_one
    
  - join: user_order_facts
    view_label: 'Users'
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${users.id}
    

- explore: journey_mapping
  label: '(7) Customer Journey Mapping'
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
