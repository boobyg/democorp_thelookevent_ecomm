- view: order_items_share_of_wallet
  view_label: 'Share of Wallet'
  fields:
#   
#   - measure: total_sale_price
#     type: sum
#     value_format: '$#,###'
#     sql: ${sale_price}
#     


########## Comparison for Share of Wallet ########## 

  - filter: item_name
    suggest_dimension: products.item_name
    
  - filter: brand
    suggest_dimension: products.brand  
    
  - dimension: primary_key
    sql: ${order_items.id}
    primary_key: true
    hidden: true
    
  - dimension: item_comparison
    description: 'Compare a selected item vs. other items in the brand vs. all other brands'
    sql: |
        CASE
        WHEN {% condition item_name %} trim(products.item_name) {% endcondition %}
        THEN '(1) '||${products.item_name}
        WHEN  {% condition brand %} trim(products.brand) {% endcondition %}
        THEN '(2) Rest of '||${products.brand}
        ELSE '(3) Rest of Population'
        END
  
  - dimension: brand_comparison
    description: 'Compare a selected brand vs. all other brands'
    sql: |
        CASE
        WHEN  {% condition brand %} trim(products.brand) {% endcondition %}
        THEN '(1) Rest of '||${products.brand}
        ELSE '(2) Rest of Population'
        END

  - measure: total_sale_price_this_item
    type: sum
    hidden: true
    sql: ${order_items.sale_price}
    value_format_name: usd
    filters:
      order_items_share_of_wallet.item_comparison: '(1)%'

  - measure: total_sale_price_this_brand
    type: sum
    hidden: true
    value_format_name: usd
    sql: ${order_items.sale_price}
    filters:
      order_items_share_of_wallet.item_comparison: '(2)%,(1)%'
      
  - measure: total_sale_price_brand_v2
    type: sum
#     hidden: true
    value_format_name: usd
    sql: ${order_items.sale_price}
    filters:
      order_items_share_of_wallet.brand_comparison: '(1)%'
      
    
  - measure: item_share_of_wallet_within_brand
    type: number
    description: 'This item sales over all sales for same brand'
#     view_label: 'Share of Wallet'
    value_format_name: percent_2
    sql: 100.0 *  ${total_sale_price_this_item}*1.0 / nullif(${total_sale_price_this_brand},0)
   
  - measure: item_share_of_wallet_within_company
    description: 'This item sales over all sales across website'
    value_format_name: percent_2
#     view_label: 'Share of Wallet'
    type: number
    sql: 100.0 *  ${total_sale_price_this_item}*1.0 / nullif(${order_items.total_sale_price},0)

  - measure: brand_share_of_wallet_within_company
    description: 'This brand''s sales over all sales across website'
    value_format_name: percent_2
#     view_label: 'Share of Wallet'
    type: number
    sql: 100.0 *  ${total_sale_price_brand_v2}*1.0 / nullif(${order_items.total_sale_price},0)
