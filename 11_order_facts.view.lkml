view: order_facts {
  derived_table: {
    sql: SELECT
          order_items.order_id AS order_id
        , COUNT(*) AS items_in_order
        , SUM(sale_price) AS order_amount
        , SUM(inventory_items.cost) AS order_cost
        , RANK() OVER (PARTITION BY order_items.user_id ORDER BY order_items.created_at) AS order_sequence_number
      FROM order_items AS order_items
      LEFT JOIN inventory_items AS inventory_items
        ON order_items.inventory_item_id = inventory_items.id
      GROUP BY order_items.order_id, order_items.user_id, order_items.created_at
       ;;
    sortkeys: ["order_id"]
    distribution: "order_id"
    sql_trigger_value: SELECT MAX(created_at) FROM order_items ;;
  }

  ## DIMENSIONS ##

  dimension: order_id {
    type: number
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: items_in_order {
    type: number
    sql: ${TABLE}.items_in_order ;;
  }

  dimension: order_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.order_amount ;;
  }

  dimension: order_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.order_cost ;;
  }

  dimension: order_sequence_number {
    type: number
    sql: ${TABLE}.order_sequence_number ;;
  }

  dimension: is_first_purchase {
    type: yesno
    sql: ${order_sequence_number} = 1 ;;
  }
}
