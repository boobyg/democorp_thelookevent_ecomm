view: total_items_stats {
# If necessary, uncomment the line below to include explore_source.

# include: "thelook.model.lkml"
  derived_table: {
    explore_source: order_items {
      column: id  {field: order_items.id}
      column: inventory_item_id {field: order_items.inventory_item_id}
      column: sale_price {}
      column: created_raw{}
      column: days_to_process {}
    }
    partition_keys: ["created_raw"]
    datagroup_trigger: ecommerce_etl
  }
  dimension: id {
    type: number
    primary_key: yes
  }
  dimension: inventory_item_id {
    label: "Batch ID"
    type: number
  }
  dimension: created_raw {
    hidden:   yes
    type:  date_time
  }
  dimension_group: created_date_group {
    label: "Created Date"
    type: time
    timeframes: [date, week, month, raw, time]
    sql: CAST (${created_raw} AS TIMESTAMP);;
    drill_fields:  [drills*]
  }

  dimension: days_to_process {
    label: "Paste Code"
    type: number
  }
  dimension: sale_price {
    type:  number
    hidden: yes
  }


  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name: eur
  }

  measure: std_dev_sale_price {
    type: number
    sql: STDDEV(${sale_price}) ;;
    value_format_name: eur
    hidden: yes
  }




#   measure: a_plus_sd_sales_price{
#     label: "A+1SD"
#     type: average
#     hidden:  no
#     value_format_name: decimal_2
#     sql:
#     (${average_sale_price}) + ${std_dev_sale_price}   ;;  #to force exception
# #    (AVG(weight_pounds) + STDDEV(weight_pounds) * 4)
#     }

#     measure: a_minus_sd_sales_price{
#       label: "A-1SD"
#       hidden:  no
#       type: average
#       value_format_name: decimal_2
#       sql: (${average_sale_price}) - ${std_dev_sale_price}   ;;
#     }

#     measure: a_plus_2sd_sales_price{
#       label: "A+2SD"
#       hidden:  no
#       type: average
#       value_format_name: decimal_2
#       sql: (${average_sale_price}) + ${std_dev_sale_price} * 2   ;;
#     }

#     measure: a_minus_2sd_sales_price{
#       label: "A-2SD"
#       hidden:  no
#       type: average
#       value_format_name: decimal_2
#       sql: (${average_sale_price}) -${std_dev_sale_price} * 2    ;;
#     }
#     measure: a_plus_3sd_sales_price{
#       label: "A+3SD"
#       hidden:  no
#       type: average
#       value_format_name: decimal_2
#       sql: (${average_sale_price}) + ${std_dev_sale_price} * 3  ;;
#     }

#     measure: a_minus_3sd_sales_price{
#       label: "A-3SD"
#       hidden:  no
#       type: average
#       value_format_name: decimal_2
#       sql: (${average_sale_price}) -${std_dev_sale_price} * 3   ;;
#     }
#     # dimension: four_or_five_batches {
#     #   label: "4 or 5 batches"
#     #   type: string
#     #   hidden: no
#     #   suggestions: ["4","5"]
#     #   sql: "four_or_five_batches" ;;
#     # }

#     parameter: reference {
#       type: string
#       allowed_value: {
#         label: "5"
#         value: "5"
#       }
#       allowed_value: {
#         label: "4"
#         value: "4"
#       }
#     }
#     dimension: four_or_five_batches {
#       type: string
#       sql:
#           {% if reference._parameter_value == "'4'" %}   '4'
#             {% else %}  '5'
#             {% endif %};;
#       #    --${TABLE}.{% parameter reference %} ;;
#       }

#       measure: exceeds_stddev_plus {
#         type: number
#         sql:    if(${sale_price_m}>${a_plus_sd_sales_price},1,0)    ;;
#       }

#       measure: exceeds_stddev_minus {
#         type: number
#         sql:    if(${sale_price_m}<${a_minus_sd_sales_price} AND ${sale_price_m}<=${a_plus_sd_sales_price}     ,-1,0)    ;;    # plus takes precedence
#       }
#       measure: exceeds_2stddev_plus {
#         type: number
#         sql:    if(${sale_price_m}>${a_plus_2sd_sales_price},1,0)    ;;
#       }

#       measure: exceeds_2stddev_minus {
#         type: number
#         sql:    if(${sale_price_m}<${a_minus_2sd_sales_price} AND ${sale_price_m}<=${a_plus_2sd_sales_price}     ,-1,0)    ;;    # plus takes precedence
#       }
#       measure: exceeds_3stddev_plus {
#         type: number
#         sql:    if(${sale_price_m}>${a_plus_3sd_sales_price},1,0)    ;;
#       }

#       measure: exceeds_3stddev_minus {
#         type: number
#         sql:    if(${sale_price_m}<${a_minus_3sd_sales_price} AND ${sale_price_m}<=${a_plus_3sd_sales_price}     ,-1,0)    ;;    # plus takes precedence
#       }


#   dimension: exceeds_stddev_d {
#     type: number
#     sql: 1 ;;
# #need DT    sql: ${exceeds_stddev} ;;
#   }
#   measure: list {
#     type: list
#     list_field: exceeds_stddev_d
# #    sql: CAST(${exceeds_stddev} As LIST) ;;
#   }

#   measure: exceeds_4_times {
#     type: string
#   #    sql: GROUP_CONCAT(${exceeds_stddev}) ;;
#   #     html: <b> {{ value }} </b> ;;
#     sql:
#     if(sum(offset(${list},0,4)) 1,0);;
#         html: {% if {{value}}>=4, %}
#           <p><img src="http://findicons.com/files/icons/573/must_have/48/check.png" height=20 width=20>1</p>
#       {% endif %}
#   ;;
#     }
#          <p><img src="http://findicons.com/files/icons/573/must_have/48/check.png" height=20 width=20>{{ rendered_value }}</p>

      #     {% elsif value == 'Processing' %}
      #   <p><img src="http://findicons.com/files/icons/1681/siena/128/clock_blue.png" height=20 width=20>{{ rendered_value }}</p>
      # {% else %}
      #   <p><img src="http://findicons.com/files/icons/719/crystal_clear_actions/64/cancel.png" height=20 width=20>{{ rendered_value }}</p>

      drill_fields:  [drills*]
      set: drills {
        # fields: [created_date_group_date, a_minus_sd_sales_price,a_minus_2sd_sales_price,a_plus_sd_sales_price,a_plus_2sd_sales_price, exceeds_stddev_plus, exceeds_stddev_minus]
        fields: [created_date_group_date]
      }
    }
