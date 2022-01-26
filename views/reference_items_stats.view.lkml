view: reference_items_stats {
  derived_table: {
    explore_source: total_items_stats {
      column: average_sale_price {}
      column: std_dev_sale_price {}
      bind_all_filters: yes
    }
  }

  dimension: dummy_column {
    primary_key: yes
    hidden: yes
    type: number
    sql: 1 ;;
  }

  dimension: average_sale_price_dim {
    sql: ${TABLE}.average_sale_price ;;
    type: number
    hidden: yes
  }

  parameter:  std_dev_sale_price_stat{
    type: number
  }

  dimension: std_dev_sale_price_dim {   #has to be fixed on the previous screen
#    sql: ${TABLE}.std_dev_sale_price ;;
    sql:  {% if std_dev_sale_price_stat._parameter_value  != "NULL"%}
      {{std_dev_sale_price_stat._parameter_value }} *.6
    {% else %}
      ${TABLE}.std_dev_sale_price *.6
   {%endif%};;
    type: number
    hidden: yes
  }

  measure: average_sale_price {
    type: average
#    sql: ${average_sale_price_dim} ;;
    sql:  {% if average_sale_price_stat._parameter_value  != "NULL"%}
    {{average_sale_price_stat._parameter_value}}
    {% else %}
    ${average_sale_price_dim}
    {%endif%};;
    link: {
      label: "Warnings Dashboard"
      url: "/dashboards/8?Created+Date+Date={{_filters['total_items_stats.created_date_group_date'] | encode_uri }}&Paste+Code={{_filters['total_items_stats.days_to_process']}}&Batch+ID={{_filters['total_items_stats.inventory_item_id']}}&Average+Sale+Price+Stat={{value}}&Std+Dev+Sale+Price+Stat={{reference_items_stats.std_dev_sale_price._value}}"
    }
  }
  parameter:  average_sale_price_stat{
    type: number
  }
  measure: std_dev_sale_price {
    type: average
    sql: ${std_dev_sale_price_dim} ;;
  }

  measure: a_plus_sd_sales_price{
    label: "A+1SD"
    type: number
    hidden:  no
    value_format_name: decimal_2
    sql:    ${average_sale_price} + ${std_dev_sale_price}   ;;
  }

  measure: a_minus_sd_sales_price{
    label: "A-1SD"
    hidden:  no
    type: number
    value_format_name: decimal_2
    sql: ${average_sale_price} - ${std_dev_sale_price}   ;;
  }

  measure: a_plus_2sd_sales_price{
    label: "A+2SD"
    hidden:  no
    type: number
    value_format_name: decimal_2
    sql: ${average_sale_price} + ${std_dev_sale_price} * 2   ;;
  }

  measure: a_minus_2sd_sales_price{
    label: "A-2SD"
    hidden:  no
    type: number
    value_format_name: decimal_2
    sql: ${average_sale_price} -${std_dev_sale_price} * 2    ;;
  }
  measure: a_plus_3sd_sales_price{
    label: "A+3SD"
    hidden:  no
    type: number
    value_format_name: decimal_2
    sql: ${average_sale_price} + ${std_dev_sale_price} * 3  ;;
  }

  measure: a_minus_3sd_sales_price{
    label: "A-3SD"
    hidden:  no
    type: number
    value_format_name: decimal_2
    sql: ${average_sale_price} -${std_dev_sale_price} * 3   ;;
  }
  # dimension: four_or_five_batches {
  #   label: "4 or 5 batches"
  #   type: string
  #   hidden: no
  #   suggestions: ["4","5"]
  #   sql: "four_or_five_batches" ;;
  # }

  # parameter: reference {
  #   type: string
  #   allowed_value: {
  #     label: "5"
  #     value: "5"
  #   }
  #   allowed_value: {
  #     label: "4"
  #     value: "4"
  #   }
  # }
  # dimension: four_or_five_batches {
  #   type: string
  #   sql:
  #       {% if reference._parameter_value == "'4'" %}   '4'
  #         {% else %}  '5'
  #         {% endif %};;
  #   #    --${TABLE}.{% parameter reference %} ;;
  #   }

    measure: exceeds_stddev_plus {
      type: number
      sql:    if(${total_items_stats.average_sale_price}>${a_plus_sd_sales_price},1,0)    ;;
    }

    measure: exceeds_stddev_minus {
      type: number
      sql:    if(${total_items_stats.average_sale_price}<${a_minus_sd_sales_price} AND ${total_items_stats.average_sale_price}<=${a_plus_sd_sales_price}     ,-1,0)    ;;    # plus takes precedence
    }
    measure: exceeds_2stddev_plus {
      type: number
      sql:    if(${total_items_stats.average_sale_price}>${a_plus_2sd_sales_price},1,0)    ;;
    }

    measure: exceeds_2stddev_minus {
      type: number
      sql:    if(${total_items_stats.average_sale_price}<${a_minus_2sd_sales_price} AND ${total_items_stats.average_sale_price}<=${a_plus_2sd_sales_price}     ,-1,0)    ;;    # plus takes precedence
    }
    measure: exceeds_3stddev_plus {
      type: number
      sql:    if(${total_items_stats.average_sale_price}>${a_plus_3sd_sales_price},1,0)    ;;
    }

    measure: exceeds_3stddev_minus {
      type: number
      sql:    if(${total_items_stats.average_sale_price}<${a_minus_3sd_sales_price} AND ${total_items_stats.average_sale_price}<=${a_plus_3sd_sales_price}     ,-1,0)    ;;    # plus takes precedence
    }



}
