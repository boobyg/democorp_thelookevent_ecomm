- connection: demonew_events_ecommerce
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
      sql_on: ${order_items.user_id} = ${users.id} 
    
    - join: user_order_facts
      view_label: 'Users'
      relationship: many_to_one
      sql_on: ${user_order_facts.user_id} = ${order_items.user_id}

    - join: products
      relationship: many_to_one
      sql_on: ${products.id} = ${inventory_items.product_id}

    - join: repeat_purchase_facts
      relationship: many_to_one
      type: full_outer
      sql_on: ${order_items.order_id} = ${repeat_purchase_facts.order_id}

    - join: distribution_centers
      type: left_outer
      sql_on: ${distribution_centers.id} = ${inventory_items.product_distribution_center_id}
      relationship: many_to_one


########################################
#########  Event Data Explores #########
########################################


- explore: events
  label: '(2) Web Event Data'
  joins:
    - join: sessions
      sql_on: ${events.session_id} =  ${sessions.session_id}
      relationship: many_to_one

    - join: session_landing_page
      from: events
      sql_on: ${sessions.landing_event_id} = ${session_landing_page.event_id}
      fields: [simple_page_info*]
      relationship: one_to_one

    - join: session_bounce_page
      from: events
      sql_on: ${sessions.bounce_event_id} = ${session_bounce_page.event_id}
      fields: [simple_page_info*]
      relationship: many_to_one
      
    - join: product_viewed
      from: products
      sql_on: ${events.viewed_product_id} = ${product_viewed.id}
      relationship: many_to_one

    - join: users
      sql_on: ${sessions.session_user_id} = ${users.id}
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

    - join: product_viewed
      from: products
      sql_on: ${events.viewed_product_id} = ${product_viewed.id}
      relationship: many_to_one
      
    - join: session_landing_page
      from: events
      sql_on: ${sessions.landing_event_id} = ${session_landing_page.event_id}
      fields: [simple_page_info*]
      relationship: one_to_one

    - join: session_bounce_page
      from: events
      sql_on: ${sessions.bounce_event_id} = ${session_bounce_page.event_id}
      fields: [simple_page_info*]
      relationship: one_to_one
      
    - join: users
      relationship: many_to_one
      sql_on: ${users.id} = ${sessions.session_user_id}
    
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

      
- explore: orders_with_share_of_wallet_application
  label: '(5) Share of Wallet Analysis'
  extends: order_items
  view: order_items
  joins: 
    - join: order_items_share_of_wallet
      view_label: 'Share of Wallet'

- explore: journey_mapping
  label: '(6) Customer Journey Mapping'
  extends: order_items
  joins:
    - join: next_order_items
      from: order_items
      sql_on: ${repeat_purchase_facts.next_order_id} = ${next_order_items.order_id}
      relationship: many_to_many

    - join: next_order_inventory_items
      from: inventory_items
      relationship: many_to_one
      sql_on: ${next_order_items.inventory_item_id} = ${inventory_items.id}
    
    - join: next_order_products
      from: products
      relationship: many_to_one
      sql_on: ${next_order_inventory_items.product_id} = ${next_order_products.id}
      
