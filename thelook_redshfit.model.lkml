connection: "thelook_events"
persist_for: "1 hour"  # cache all query results for one hour
label: "1) eCommerce with Event Data"


include: "*.view" # include all the views
include: "*.dashboard" # include all the dashboards


############ Base Explores #############

explore: order_items {
  label: "(1) Orders, Items and Users"
  view_name: order_items
  description: "Explore data about Orders"

  join: order_facts {
    view_label: "Orders"
    relationship: many_to_one
    sql_on: ${order_facts.order_id} = ${order_items.order_id} ;;
  }

  join: inventory_items {
    #Left Join only brings in items that have been sold as order_item
    type: full_outer
    relationship: one_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }

  join: users {
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }

  join: user_order_facts {
    view_label: "Users"
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${order_items.user_id} ;;
  }

  join: products {
    relationship: many_to_one
    sql_on: ${products.id} = ${inventory_items.product_id} ;;
  }

  join: repeat_purchase_facts {
    relationship: many_to_one
    type: full_outer
    sql_on: ${order_items.order_id} = ${repeat_purchase_facts.order_id} ;;
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${distribution_centers.id} = ${inventory_items.product_distribution_center_id} ;;
    relationship: many_to_one
  }

  query: order_items_by_created_date {
    dimensions: [ order_items.created_date]
    measures: [order_items.count]
    sort: {field:order_items.count desc:yes}
    description: "For time series analysis of items ordered by date"
  }

  query: order_items_by_created_date_ytd {
    label: "Order Items by Created Date (YTD)"
    dimensions: [ order_items.created_date]
    measures: [order_items.count]
    sort: {field:order_items.count desc:yes}
    description: "Limit to current calendar year"
  }

  query: orders_by_department {
    dimensions: [products.department]
    measures: [order_items.count]
    description: "Department-level analysis of orders (Clothing, Kitchen, Furniture, etc."
  }
}


#########  Event Data Explores #########

explore: events {
  label: "(2) Web Event Data"
  always_filter: {
    filters: [event_date: "7 days"]
  }

  join: sessions {
    sql_on: ${events.session_id} =  ${sessions.session_id} ;;
    relationship: many_to_one
  }

  join: session_landing_page {
    from: events
    sql_on: ${sessions.landing_event_id} = ${session_landing_page.event_id} ;;
    fields: [simple_page_info*]
    relationship: one_to_one
  }

  join: session_bounce_page {
    from: events
    sql_on: ${sessions.bounce_event_id} = ${session_bounce_page.event_id} ;;
    fields: [simple_page_info*]
    relationship: many_to_one
  }

  join: product_viewed {
    from: products
    sql_on: ${events.viewed_product_id} = ${product_viewed.id} ;;
    relationship: many_to_one
  }

  join: users {
    sql_on: ${sessions.session_user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_order_facts {
    sql_on: ${users.id} = ${user_order_facts.user_id} ;;
    relationship: one_to_one
    view_label: "Users"
  }

  query: event_count_by_type {
    dimensions: [events.event_type]
    measures: [events.count]
  }
}

explore: sessions {
  label: "(3) Web Session Data"

  join: events {
    sql_on: ${sessions.session_id} = ${events.session_id} ;;
    relationship: one_to_many
  }

  join: product_viewed {
    from: products
    sql_on: ${events.viewed_product_id} = ${product_viewed.id} ;;
    relationship: many_to_one
  }

  join: session_landing_page {
    from: events
    sql_on: ${sessions.landing_event_id} = ${session_landing_page.event_id} ;;
    fields: [session_landing_page.simple_page_info*]
    relationship: one_to_one
  }

  join: session_bounce_page {
    from: events
    sql_on: ${sessions.bounce_event_id} = ${session_bounce_page.event_id} ;;
    fields: [session_bounce_page.simple_page_info*]
    relationship: one_to_one
  }

  join: users {
    relationship: many_to_one
    sql_on: ${users.id} = ${sessions.session_user_id} ;;
  }

  join: user_order_facts {
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${users.id} ;;
    view_label: "Users"
  }
}


#########  Advanced Extensions #########

explore: affinity {
  label: "(4) Affinity Analysis"

  always_filter: {
    filters: {
      field: affinity.product_b_id
      value: "-NULL"
    }
  }

  join: product_a {
    from: products
    view_label: "Product A Details"
    relationship: many_to_one
    sql_on: ${affinity.product_a_id} = ${product_a.id} ;;
  }

  join: product_b {
    from: products
    view_label: "Product B Details"
    relationship: many_to_one
    sql_on: ${affinity.product_b_id} = ${product_b.id} ;;
  }
}

explore: orders_with_share_of_wallet_application {
  label: "(5) Share of Wallet Analysis"
  extends: [order_items]
  view_name: order_items

  join: order_items_share_of_wallet {
    view_label: "Share of Wallet"
  }
}

explore: journey_mapping {
  label: "(6) Customer Journey Mapping"
  extends: [order_items]
  view_name: order_items

  join: repeat_purchase_facts {
    relationship: many_to_one
    sql_on: ${repeat_purchase_facts.next_order_id} = ${order_items.order_id} ;;
    type: left_outer
  }

  join: next_order_items {
    from: order_items
    sql_on: ${repeat_purchase_facts.next_order_id} = ${next_order_items.order_id} ;;
    relationship: many_to_many
  }

  join: next_order_inventory_items {
    from: inventory_items
    relationship: many_to_one
    sql_on: ${next_order_items.inventory_item_id} = ${next_order_inventory_items.id} ;;
  }

  join: next_order_products {
    from: products
    relationship: many_to_one
    sql_on: ${next_order_inventory_items.product_id} = ${next_order_products.id} ;;
  }
}


explore: inventory_items{
  label: "(7) Stock Analysis"
  fields: [ALL_FIELDS*,-order_items.median_sale_price]

  join: order_facts {
    view_label: "Orders"
    relationship: many_to_one
    sql_on: ${order_facts.order_id} = ${order_items.order_id} ;;
  }

  join: order_items {
    #Left Join only brings in items that have been sold as order_item
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }

  join: users {
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }

  join: user_order_facts {
    view_label: "Users"
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${order_items.user_id} ;;
  }

  join: products {
    relationship: many_to_one
    sql_on: ${products.id} = ${inventory_items.product_id} ;;
  }

  join: repeat_purchase_facts {
    relationship: many_to_one
    type: full_outer
    sql_on: ${order_items.order_id} = ${repeat_purchase_facts.order_id} ;;
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${distribution_centers.id} = ${inventory_items.product_distribution_center_id} ;;
    relationship: many_to_one
  }
}

explore: inventory_snapshot {
  label: "(8) Historical Stock Snapshot Analysis"
  join: trailing_sales_snapshot {
    sql_on: ${inventory_snapshot.product_id}=${trailing_sales_snapshot.product_id}
    AND ${inventory_snapshot.snapshot_date}=${trailing_sales_snapshot.snapshot_date};;
    type: left_outer
    relationship: one_to_one
  }

  join: products {
    sql_on: ${inventory_snapshot.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    sql_on: ${products.distribution_center_id}=${distribution_centers.id} ;;
    relationship: many_to_one
  }
}




explore: bigger_list {
  view_name: users
  join: users2 {from:users foreign_key: users.id}
  join: users3 {from:users foreign_key: users.id}
  join: users4 {from:users foreign_key: users.id}
  join: users5 {from:users foreign_key: users.id}
  join: users6 {from:users foreign_key: users.id}
  join: users7 {from:users foreign_key: users.id}
  join: users8 {from:users foreign_key: users.id}
  join: users9 {from:users foreign_key: users.id}
  join: users10 {from:users foreign_key: users.id}
  join: users11 {from:users foreign_key: users.id}
  join: users12 {from:users foreign_key: users.id}
  join: users13 {from:users foreign_key: users.id}
  join: users14 {from:users foreign_key: users.id}
  join: users15 {from:users foreign_key: users.id}
  join: users16 {from:users foreign_key: users.id}
  join: users17 {from:users foreign_key: users.id}
  join: users18 {from:users foreign_key: users.id}
  join: users19 {from:users foreign_key: users.id}
  join: users20 {from:users foreign_key: users.id}
  join: users21 {from:users foreign_key: users.id}
  join: users22 {from:users foreign_key: users.id}
  join: users23 {from:users foreign_key: users.id}
  join: users24 {from:users foreign_key: users.id}
  join: users25 {from:users foreign_key: users.id}
  join: users26 {from:users foreign_key: users.id}
  join: users27 {from:users foreign_key: users.id}
  join: users28 {from:users foreign_key: users.id}
  join: users29 {from:users foreign_key: users.id}
  join: users30 {from:users foreign_key: users.id}
  join: users31 {from:users foreign_key: users.id}
  join: users32 {from:users foreign_key: users.id}
  join: users33 {from:users foreign_key: users.id}
  join: users34 {from:users foreign_key: users.id}
  join: users35 {from:users foreign_key: users.id}
  join: users36 {from:users foreign_key: users.id}
  join: users37 {from:users foreign_key: users.id}
  join: users38 {from:users foreign_key: users.id}
  join: users39 {from:users foreign_key: users.id}
  join: users40 {from:users foreign_key: users.id}
  join: users41 {from:users foreign_key: users.id}
  join: users42 {from:users foreign_key: users.id}
  join: users43 {from:users foreign_key: users.id}
  join: users44 {from:users foreign_key: users.id}
  join: users45 {from:users foreign_key: users.id}
  join: users46 {from:users foreign_key: users.id}
  join: users47 {from:users foreign_key: users.id}
  join: users48 {from:users foreign_key: users.id}
  join: users49 {from:users foreign_key: users.id}
  join: users50 {from:users foreign_key: users.id}
  join: users51 {from:users foreign_key: users.id}
  join: users52 {from:users foreign_key: users.id}
  join: users53 {from:users foreign_key: users.id}
  join: users54 {from:users foreign_key: users.id}
  join: users55 {from:users foreign_key: users.id}
  join: users56 {from:users foreign_key: users.id}
  join: users57 {from:users foreign_key: users.id}
  join: users58 {from:users foreign_key: users.id}
  join: users59 {from:users foreign_key: users.id}
  join: users60 {from:users foreign_key: users.id}
  join: users61 {from:users foreign_key: users.id}
  join: users62 {from:users foreign_key: users.id}
  join: users63 {from:users foreign_key: users.id}
  join: users64 {from:users foreign_key: users.id}
  join: users65 {from:users foreign_key: users.id}
  join: users66 {from:users foreign_key: users.id}
  join: users67 {from:users foreign_key: users.id}
  join: users68 {from:users foreign_key: users.id}
  join: users69 {from:users foreign_key: users.id}
  join: users70 {from:users foreign_key: users.id}
  join: users71 {from:users foreign_key: users.id}
  join: users72 {from:users foreign_key: users.id}
  join: users73 {from:users foreign_key: users.id}
  join: users74 {from:users foreign_key: users.id}
  join: users75 {from:users foreign_key: users.id}
  join: users76 {from:users foreign_key: users.id}
  join: users77 {from:users foreign_key: users.id}
  join: users78 {from:users foreign_key: users.id}
  join: users79 {from:users foreign_key: users.id}
  join: users80 {from:users foreign_key: users.id}
  join: users81 {from:users foreign_key: users.id}
  join: users82 {from:users foreign_key: users.id}
  join: users83 {from:users foreign_key: users.id}
  join: users84 {from:users foreign_key: users.id}
  join: users85 {from:users foreign_key: users.id}
  join: users86 {from:users foreign_key: users.id}
  join: users87 {from:users foreign_key: users.id}
  join: users88 {from:users foreign_key: users.id}
  join: users89 {from:users foreign_key: users.id}
  join: users90 {from:users foreign_key: users.id}
  join: users91 {from:users foreign_key: users.id}
  join: users92 {from:users foreign_key: users.id}
  join: users93 {from:users foreign_key: users.id}
  join: users94 {from:users foreign_key: users.id}
  join: users95 {from:users foreign_key: users.id}
  join: users96 {from:users foreign_key: users.id}
  join: users97 {from:users foreign_key: users.id}
  join: users98 {from:users foreign_key: users.id}
  join: users99 {from:users foreign_key: users.id}
  join: users100 {from:users foreign_key: users.id}
  join: users101 {from:users foreign_key: users.id}
  join: users102 {from:users foreign_key: users.id}
  join: users103 {from:users foreign_key: users.id}
  join: users104 {from:users foreign_key: users.id}
  join: users105 {from:users foreign_key: users.id}
  join: users106 {from:users foreign_key: users.id}
  join: users107 {from:users foreign_key: users.id}
  join: users108 {from:users foreign_key: users.id}
  join: users109 {from:users foreign_key: users.id}
  join: users110 {from:users foreign_key: users.id}
  join: users111 {from:users foreign_key: users.id}
  join: users112 {from:users foreign_key: users.id}
  join: users113 {from:users foreign_key: users.id}
  join: users114 {from:users foreign_key: users.id}
  join: users115 {from:users foreign_key: users.id}
  join: users116 {from:users foreign_key: users.id}
  join: users117 {from:users foreign_key: users.id}
  join: users118 {from:users foreign_key: users.id}
  join: users119 {from:users foreign_key: users.id}
  join: users120 {from:users foreign_key: users.id}
  join: users121 {from:users foreign_key: users.id}
  join: users122 {from:users foreign_key: users.id}
  join: users123 {from:users foreign_key: users.id}
  join: users124 {from:users foreign_key: users.id}
  join: users125 {from:users foreign_key: users.id}
  join: users126 {from:users foreign_key: users.id}
  join: users127 {from:users foreign_key: users.id}
  join: users128 {from:users foreign_key: users.id}
  join: users129 {from:users foreign_key: users.id}
  join: users130 {from:users foreign_key: users.id}
  join: users131 {from:users foreign_key: users.id}
  join: users132 {from:users foreign_key: users.id}
  join: users133 {from:users foreign_key: users.id}
  join: users134 {from:users foreign_key: users.id}
  join: users135 {from:users foreign_key: users.id}
  join: users136 {from:users foreign_key: users.id}
  join: users137 {from:users foreign_key: users.id}
  join: users138 {from:users foreign_key: users.id}
  join: users139 {from:users foreign_key: users.id}
  join: users140 {from:users foreign_key: users.id}
  join: users141 {from:users foreign_key: users.id}
  join: users142 {from:users foreign_key: users.id}
  join: users143 {from:users foreign_key: users.id}
  join: users144 {from:users foreign_key: users.id}
  join: users145 {from:users foreign_key: users.id}
  join: users146 {from:users foreign_key: users.id}
  join: users147 {from:users foreign_key: users.id}
  join: users148 {from:users foreign_key: users.id}
  join: users149 {from:users foreign_key: users.id}
  join: users150 {from:users foreign_key: users.id}
  join: users151 {from:users foreign_key: users.id}
  join: users152 {from:users foreign_key: users.id}
  join: users153 {from:users foreign_key: users.id}
  join: users154 {from:users foreign_key: users.id}
  join: users155 {from:users foreign_key: users.id}
  join: users156 {from:users foreign_key: users.id}
  join: users157 {from:users foreign_key: users.id}
  join: users158 {from:users foreign_key: users.id}
  join: users159 {from:users foreign_key: users.id}
  join: users160 {from:users foreign_key: users.id}
  join: users161 {from:users foreign_key: users.id}
  join: users162 {from:users foreign_key: users.id}
  join: users163 {from:users foreign_key: users.id}
  join: users164 {from:users foreign_key: users.id}
  join: users165 {from:users foreign_key: users.id}
  join: users166 {from:users foreign_key: users.id}
  join: users167 {from:users foreign_key: users.id}
  join: users168 {from:users foreign_key: users.id}
  join: users169 {from:users foreign_key: users.id}
  join: users170 {from:users foreign_key: users.id}
  join: users171 {from:users foreign_key: users.id}
  join: users172 {from:users foreign_key: users.id}
  join: users173 {from:users foreign_key: users.id}
  join: users174 {from:users foreign_key: users.id}
  join: users175 {from:users foreign_key: users.id}
  join: users176 {from:users foreign_key: users.id}
  join: users177 {from:users foreign_key: users.id}
  join: users178 {from:users foreign_key: users.id}
  join: users179 {from:users foreign_key: users.id}
  join: users180 {from:users foreign_key: users.id}
  join: users181 {from:users foreign_key: users.id}
  join: users182 {from:users foreign_key: users.id}
  join: users183 {from:users foreign_key: users.id}
  join: users184 {from:users foreign_key: users.id}
  join: users185 {from:users foreign_key: users.id}
  join: users186 {from:users foreign_key: users.id}
  join: users187 {from:users foreign_key: users.id}
  join: users188 {from:users foreign_key: users.id}
  join: users189 {from:users foreign_key: users.id}
  join: users190 {from:users foreign_key: users.id}
  join: users191 {from:users foreign_key: users.id}
  join: users192 {from:users foreign_key: users.id}
  join: users193 {from:users foreign_key: users.id}
  join: users194 {from:users foreign_key: users.id}
  join: users195 {from:users foreign_key: users.id}
  join: users196 {from:users foreign_key: users.id}
  join: users197 {from:users foreign_key: users.id}
  join: users198 {from:users foreign_key: users.id}
  join: users199 {from:users foreign_key: users.id}
#   join: users200 {from:users foreign_key: users.id}
#   join: users201 {from:users foreign_key: users.id}
#   join: users202 {from:users foreign_key: users.id}
#   join: users203 {from:users foreign_key: users.id}
#   join: users204 {from:users foreign_key: users.id}
#   join: users205 {from:users foreign_key: users.id}
#   join: users206 {from:users foreign_key: users.id}
#   join: users207 {from:users foreign_key: users.id}
#   join: users208 {from:users foreign_key: users.id}
#   join: users209 {from:users foreign_key: users.id}
#   join: users210 {from:users foreign_key: users.id}
#   join: users211 {from:users foreign_key: users.id}
#   join: users212 {from:users foreign_key: users.id}
#   join: users213 {from:users foreign_key: users.id}
#   join: users214 {from:users foreign_key: users.id}
#   join: users215 {from:users foreign_key: users.id}
#   join: users216 {from:users foreign_key: users.id}
#   join: users217 {from:users foreign_key: users.id}
#   join: users218 {from:users foreign_key: users.id}
#   join: users219 {from:users foreign_key: users.id}
#   join: users220 {from:users foreign_key: users.id}
#   join: users221 {from:users foreign_key: users.id}
#   join: users222 {from:users foreign_key: users.id}
#   join: users223 {from:users foreign_key: users.id}
#   join: users224 {from:users foreign_key: users.id}
#   join: users225 {from:users foreign_key: users.id}
#   join: users226 {from:users foreign_key: users.id}
#   join: users227 {from:users foreign_key: users.id}
#   join: users228 {from:users foreign_key: users.id}
#   join: users229 {from:users foreign_key: users.id}
#   join: users230 {from:users foreign_key: users.id}
#   join: users231 {from:users foreign_key: users.id}
#   join: users232 {from:users foreign_key: users.id}
#   join: users233 {from:users foreign_key: users.id}
#   join: users234 {from:users foreign_key: users.id}
#   join: users235 {from:users foreign_key: users.id}
#   join: users236 {from:users foreign_key: users.id}
#   join: users237 {from:users foreign_key: users.id}
#   join: users238 {from:users foreign_key: users.id}
#   join: users239 {from:users foreign_key: users.id}
#   join: users240 {from:users foreign_key: users.id}
#   join: users241 {from:users foreign_key: users.id}
#   join: users242 {from:users foreign_key: users.id}
#   join: users243 {from:users foreign_key: users.id}
#   join: users244 {from:users foreign_key: users.id}
#   join: users245 {from:users foreign_key: users.id}
#   join: users246 {from:users foreign_key: users.id}
#   join: users247 {from:users foreign_key: users.id}
#   join: users248 {from:users foreign_key: users.id}
#   join: users249 {from:users foreign_key: users.id}
#   join: users250 {from:users foreign_key: users.id}
#   join: users251 {from:users foreign_key: users.id}
#   join: users252 {from:users foreign_key: users.id}
#   join: users253 {from:users foreign_key: users.id}
#   join: users254 {from:users foreign_key: users.id}
#   join: users255 {from:users foreign_key: users.id}
#   join: users256 {from:users foreign_key: users.id}
#   join: users257 {from:users foreign_key: users.id}
#   join: users258 {from:users foreign_key: users.id}
#   join: users259 {from:users foreign_key: users.id}
#   join: users260 {from:users foreign_key: users.id}
#   join: users261 {from:users foreign_key: users.id}
#   join: users262 {from:users foreign_key: users.id}
#   join: users263 {from:users foreign_key: users.id}
#   join: users264 {from:users foreign_key: users.id}
#   join: users265 {from:users foreign_key: users.id}
#   join: users266 {from:users foreign_key: users.id}
#   join: users267 {from:users foreign_key: users.id}
#   join: users268 {from:users foreign_key: users.id}
#   join: users269 {from:users foreign_key: users.id}
#   join: users270 {from:users foreign_key: users.id}
#   join: users271 {from:users foreign_key: users.id}
#   join: users272 {from:users foreign_key: users.id}
#   join: users273 {from:users foreign_key: users.id}
#   join: users274 {from:users foreign_key: users.id}
#   join: users275 {from:users foreign_key: users.id}
#   join: users276 {from:users foreign_key: users.id}
#   join: users277 {from:users foreign_key: users.id}
#   join: users278 {from:users foreign_key: users.id}
#   join: users279 {from:users foreign_key: users.id}
#   join: users280 {from:users foreign_key: users.id}
#   join: users281 {from:users foreign_key: users.id}
#   join: users282 {from:users foreign_key: users.id}
#   join: users283 {from:users foreign_key: users.id}
#   join: users284 {from:users foreign_key: users.id}
#   join: users285 {from:users foreign_key: users.id}
#   join: users286 {from:users foreign_key: users.id}
#   join: users287 {from:users foreign_key: users.id}
#   join: users288 {from:users foreign_key: users.id}
#   join: users289 {from:users foreign_key: users.id}
#   join: users290 {from:users foreign_key: users.id}
#   join: users291 {from:users foreign_key: users.id}
#   join: users292 {from:users foreign_key: users.id}
#   join: users293 {from:users foreign_key: users.id}
#   join: users294 {from:users foreign_key: users.id}
#   join: users295 {from:users foreign_key: users.id}
#   join: users296 {from:users foreign_key: users.id}
#   join: users297 {from:users foreign_key: users.id}
#   join: users298 {from:users foreign_key: users.id}
#   join: users299 {from:users foreign_key: users.id}
#   join: users300 {from:users foreign_key: users.id}
#   join: users301 {from:users foreign_key: users.id}
#   join: users302 {from:users foreign_key: users.id}
#   join: users303 {from:users foreign_key: users.id}
#   join: users304 {from:users foreign_key: users.id}
#   join: users305 {from:users foreign_key: users.id}
#   join: users306 {from:users foreign_key: users.id}
#   join: users307 {from:users foreign_key: users.id}
#   join: users308 {from:users foreign_key: users.id}
#   join: users309 {from:users foreign_key: users.id}
#   join: users310 {from:users foreign_key: users.id}
#   join: users311 {from:users foreign_key: users.id}
#   join: users312 {from:users foreign_key: users.id}
#   join: users313 {from:users foreign_key: users.id}
#   join: users314 {from:users foreign_key: users.id}
#   join: users315 {from:users foreign_key: users.id}
#   join: users316 {from:users foreign_key: users.id}
#   join: users317 {from:users foreign_key: users.id}
#   join: users318 {from:users foreign_key: users.id}
#   join: users319 {from:users foreign_key: users.id}
#   join: users320 {from:users foreign_key: users.id}
#   join: users321 {from:users foreign_key: users.id}
#   join: users322 {from:users foreign_key: users.id}
#   join: users323 {from:users foreign_key: users.id}
#   join: users324 {from:users foreign_key: users.id}
#   join: users325 {from:users foreign_key: users.id}
#   join: users326 {from:users foreign_key: users.id}
#   join: users327 {from:users foreign_key: users.id}
#   join: users328 {from:users foreign_key: users.id}
#   join: users329 {from:users foreign_key: users.id}
#   join: users330 {from:users foreign_key: users.id}
#   join: users331 {from:users foreign_key: users.id}
#   join: users332 {from:users foreign_key: users.id}
#   join: users333 {from:users foreign_key: users.id}
#   join: users334 {from:users foreign_key: users.id}
#   join: users335 {from:users foreign_key: users.id}
#   join: users336 {from:users foreign_key: users.id}
#   join: users337 {from:users foreign_key: users.id}
#   join: users338 {from:users foreign_key: users.id}
#   join: users339 {from:users foreign_key: users.id}
#   join: users340 {from:users foreign_key: users.id}
#   join: users341 {from:users foreign_key: users.id}
#   join: users342 {from:users foreign_key: users.id}
#   join: users343 {from:users foreign_key: users.id}
#   join: users344 {from:users foreign_key: users.id}
#   join: users345 {from:users foreign_key: users.id}
#   join: users346 {from:users foreign_key: users.id}
#   join: users347 {from:users foreign_key: users.id}
#   join: users348 {from:users foreign_key: users.id}
#   join: users349 {from:users foreign_key: users.id}
#   join: users350 {from:users foreign_key: users.id}
#   join: users351 {from:users foreign_key: users.id}
#   join: users352 {from:users foreign_key: users.id}
#   join: users353 {from:users foreign_key: users.id}
#   join: users354 {from:users foreign_key: users.id}
#   join: users355 {from:users foreign_key: users.id}
#   join: users356 {from:users foreign_key: users.id}
#   join: users357 {from:users foreign_key: users.id}
#   join: users358 {from:users foreign_key: users.id}
#   join: users359 {from:users foreign_key: users.id}
#   join: users360 {from:users foreign_key: users.id}
#   join: users361 {from:users foreign_key: users.id}
#   join: users362 {from:users foreign_key: users.id}
#   join: users363 {from:users foreign_key: users.id}
#   join: users364 {from:users foreign_key: users.id}
#   join: users365 {from:users foreign_key: users.id}
#   join: users366 {from:users foreign_key: users.id}
#   join: users367 {from:users foreign_key: users.id}
#   join: users368 {from:users foreign_key: users.id}
#   join: users369 {from:users foreign_key: users.id}
#   join: users370 {from:users foreign_key: users.id}
#   join: users371 {from:users foreign_key: users.id}
#   join: users372 {from:users foreign_key: users.id}
#   join: users373 {from:users foreign_key: users.id}
#   join: users374 {from:users foreign_key: users.id}
#   join: users375 {from:users foreign_key: users.id}
#   join: users376 {from:users foreign_key: users.id}
#   join: users377 {from:users foreign_key: users.id}
#   join: users378 {from:users foreign_key: users.id}
#   join: users379 {from:users foreign_key: users.id}
#   join: users380 {from:users foreign_key: users.id}
#   join: users381 {from:users foreign_key: users.id}
#   join: users382 {from:users foreign_key: users.id}
#   join: users383 {from:users foreign_key: users.id}
#   join: users384 {from:users foreign_key: users.id}
#   join: users385 {from:users foreign_key: users.id}
#   join: users386 {from:users foreign_key: users.id}
#   join: users387 {from:users foreign_key: users.id}
#   join: users388 {from:users foreign_key: users.id}
#   join: users389 {from:users foreign_key: users.id}
#   join: users390 {from:users foreign_key: users.id}
#   join: users391 {from:users foreign_key: users.id}
#   join: users392 {from:users foreign_key: users.id}
#   join: users393 {from:users foreign_key: users.id}
#   join: users394 {from:users foreign_key: users.id}
#   join: users395 {from:users foreign_key: users.id}
#   join: users396 {from:users foreign_key: users.id}
#   join: users397 {from:users foreign_key: users.id}
#   join: users398 {from:users foreign_key: users.id}
#   join: users399 {from:users foreign_key: users.id}
#   join: users400 {from:users foreign_key: users.id}
#   join: users401 {from:users foreign_key: users.id}
#   join: users402 {from:users foreign_key: users.id}
#   join: users403 {from:users foreign_key: users.id}
#   join: users404 {from:users foreign_key: users.id}
#   join: users405 {from:users foreign_key: users.id}
#   join: users406 {from:users foreign_key: users.id}
#   join: users407 {from:users foreign_key: users.id}
#   join: users408 {from:users foreign_key: users.id}
#   join: users409 {from:users foreign_key: users.id}
#   join: users410 {from:users foreign_key: users.id}
#   join: users411 {from:users foreign_key: users.id}
#   join: users412 {from:users foreign_key: users.id}
#   join: users413 {from:users foreign_key: users.id}
#   join: users414 {from:users foreign_key: users.id}
#   join: users415 {from:users foreign_key: users.id}
#   join: users416 {from:users foreign_key: users.id}
#   join: users417 {from:users foreign_key: users.id}
#   join: users418 {from:users foreign_key: users.id}
#   join: users419 {from:users foreign_key: users.id}
#   join: users420 {from:users foreign_key: users.id}
#   join: users421 {from:users foreign_key: users.id}
#   join: users422 {from:users foreign_key: users.id}
#   join: users423 {from:users foreign_key: users.id}
#   join: users424 {from:users foreign_key: users.id}
#   join: users425 {from:users foreign_key: users.id}
#   join: users426 {from:users foreign_key: users.id}
#   join: users427 {from:users foreign_key: users.id}
#   join: users428 {from:users foreign_key: users.id}
#   join: users429 {from:users foreign_key: users.id}
#   join: users430 {from:users foreign_key: users.id}
#   join: users431 {from:users foreign_key: users.id}
#   join: users432 {from:users foreign_key: users.id}
#   join: users433 {from:users foreign_key: users.id}
#   join: users434 {from:users foreign_key: users.id}
#   join: users435 {from:users foreign_key: users.id}
#   join: users436 {from:users foreign_key: users.id}
#   join: users437 {from:users foreign_key: users.id}
#   join: users438 {from:users foreign_key: users.id}
#   join: users439 {from:users foreign_key: users.id}
#   join: users440 {from:users foreign_key: users.id}
#   join: users441 {from:users foreign_key: users.id}
#   join: users442 {from:users foreign_key: users.id}
#   join: users443 {from:users foreign_key: users.id}
#   join: users444 {from:users foreign_key: users.id}
#   join: users445 {from:users foreign_key: users.id}
#   join: users446 {from:users foreign_key: users.id}
#   join: users447 {from:users foreign_key: users.id}
#   join: users448 {from:users foreign_key: users.id}
#   join: users449 {from:users foreign_key: users.id}
#   join: users450 {from:users foreign_key: users.id}
#   join: users451 {from:users foreign_key: users.id}
#   join: users452 {from:users foreign_key: users.id}
#   join: users453 {from:users foreign_key: users.id}
#   join: users454 {from:users foreign_key: users.id}
#   join: users455 {from:users foreign_key: users.id}
#   join: users456 {from:users foreign_key: users.id}
#   join: users457 {from:users foreign_key: users.id}
#   join: users458 {from:users foreign_key: users.id}
#   join: users459 {from:users foreign_key: users.id}
#   join: users460 {from:users foreign_key: users.id}
#   join: users461 {from:users foreign_key: users.id}
#   join: users462 {from:users foreign_key: users.id}
#   join: users463 {from:users foreign_key: users.id}
#   join: users464 {from:users foreign_key: users.id}
#   join: users465 {from:users foreign_key: users.id}
#   join: users466 {from:users foreign_key: users.id}
#   join: users467 {from:users foreign_key: users.id}
#   join: users468 {from:users foreign_key: users.id}
#   join: users469 {from:users foreign_key: users.id}
#   join: users470 {from:users foreign_key: users.id}
#   join: users471 {from:users foreign_key: users.id}
#   join: users472 {from:users foreign_key: users.id}
#   join: users473 {from:users foreign_key: users.id}
#   join: users474 {from:users foreign_key: users.id}
#   join: users475 {from:users foreign_key: users.id}
#   join: users476 {from:users foreign_key: users.id}
#   join: users477 {from:users foreign_key: users.id}
#   join: users478 {from:users foreign_key: users.id}
#   join: users479 {from:users foreign_key: users.id}
#   join: users480 {from:users foreign_key: users.id}
#   join: users481 {from:users foreign_key: users.id}
#   join: users482 {from:users foreign_key: users.id}
#   join: users483 {from:users foreign_key: users.id}
#   join: users484 {from:users foreign_key: users.id}
#   join: users485 {from:users foreign_key: users.id}
#   join: users486 {from:users foreign_key: users.id}
#   join: users487 {from:users foreign_key: users.id}
#   join: users488 {from:users foreign_key: users.id}
#   join: users489 {from:users foreign_key: users.id}
#   join: users490 {from:users foreign_key: users.id}
#   join: users491 {from:users foreign_key: users.id}
#   join: users492 {from:users foreign_key: users.id}
#   join: users493 {from:users foreign_key: users.id}
#   join: users494 {from:users foreign_key: users.id}
#   join: users495 {from:users foreign_key: users.id}
#   join: users496 {from:users foreign_key: users.id}
#   join: users497 {from:users foreign_key: users.id}
#   join: users498 {from:users foreign_key: users.id}
#   join: users499 {from:users foreign_key: users.id}
#   join: users500 {from:users foreign_key: users.id}
#   join: users501 {from:users foreign_key: users.id}
#   join: users502 {from:users foreign_key: users.id}
#   join: users503 {from:users foreign_key: users.id}
#   join: users504 {from:users foreign_key: users.id}
#   join: users505 {from:users foreign_key: users.id}
#   join: users506 {from:users foreign_key: users.id}
#   join: users507 {from:users foreign_key: users.id}
#   join: users508 {from:users foreign_key: users.id}
#   join: users509 {from:users foreign_key: users.id}
#   join: users510 {from:users foreign_key: users.id}
#   join: users511 {from:users foreign_key: users.id}
#   join: users512 {from:users foreign_key: users.id}
#   join: users513 {from:users foreign_key: users.id}
#   join: users514 {from:users foreign_key: users.id}
#   join: users515 {from:users foreign_key: users.id}
#   join: users516 {from:users foreign_key: users.id}
#   join: users517 {from:users foreign_key: users.id}
#   join: users518 {from:users foreign_key: users.id}
#   join: users519 {from:users foreign_key: users.id}
#   join: users520 {from:users foreign_key: users.id}
#   join: users521 {from:users foreign_key: users.id}
#   join: users522 {from:users foreign_key: users.id}
#   join: users523 {from:users foreign_key: users.id}
#   join: users524 {from:users foreign_key: users.id}
#   join: users525 {from:users foreign_key: users.id}
#   join: users526 {from:users foreign_key: users.id}
#   join: users527 {from:users foreign_key: users.id}
#   join: users528 {from:users foreign_key: users.id}
#   join: users529 {from:users foreign_key: users.id}
#   join: users530 {from:users foreign_key: users.id}
#   join: users531 {from:users foreign_key: users.id}
#   join: users532 {from:users foreign_key: users.id}
#   join: users533 {from:users foreign_key: users.id}
#   join: users534 {from:users foreign_key: users.id}
#   join: users535 {from:users foreign_key: users.id}
#   join: users536 {from:users foreign_key: users.id}
#   join: users537 {from:users foreign_key: users.id}
#   join: users538 {from:users foreign_key: users.id}
#   join: users539 {from:users foreign_key: users.id}
#   join: users540 {from:users foreign_key: users.id}
#   join: users541 {from:users foreign_key: users.id}
#   join: users542 {from:users foreign_key: users.id}
#   join: users543 {from:users foreign_key: users.id}
#   join: users544 {from:users foreign_key: users.id}
#   join: users545 {from:users foreign_key: users.id}
#   join: users546 {from:users foreign_key: users.id}
#   join: users547 {from:users foreign_key: users.id}
#   join: users548 {from:users foreign_key: users.id}
}

















explore: kitten_order_items {
  label: "Order Items (Kittens)"
  hidden: yes
  extends: [order_items]

  join: users {
    view_label: "Kittens"
    from: kitten_users
  }
}
