# Join in a single product o all rows.
- view: product_selected
  derived_table:
    sql: |
      SELECT *
        FROM thelook.products p
        WHERE {% condition item_name %} p.item_name {% endcondition %}
        AND {% condition brand %} p.brand {% endcondition %}
  fields:
   
  - dimension: item_name
    suggest_dimension: products.item_name
    
  - dimension: brand
    suggest_dimension: products.brand
    
  - dimension: category
    suggest_dimension: products.category
    
  - dimension: comparison
    sql: |
        CASE
          WHEN ${products.item_name} = ${product_selected.item_name} 
          THEN '(1) '||${products.item_name}
          WHEN ${product_selected.brand} = ${products.brand}
          THEN '(2) Rest of '||${products.brand}
          ELSE '(3) Rest of Population'
        END

- view: order_items_share_of_wallet
  extends: order_items
  fields:
  
  - measure: total_sale_price
    type: sum
    sql: ${sale_price}
    
  - measure: total_sale_price_this_item
    type: sum
    sql: ${sale_price}
    filters:
      product_selected.comparison: '(1)%'

  - measure: total_sale_price_this_brand
    type: sum
    sql: ${sale_price}
    filters:
      product_selected.comparison: '(2)%,(1)%'
    
  - measure: share_of_wallet_within_brand
    type: number
    description: 'This item sales over all sales for same brand'
    value_format: '#.0000\%'
    sql: 100.0 *  ${total_sale_price_this_item}*1.0 / nullif(${total_sale_price_this_brand},0)

  - measure: share_of_wallet_brand_within_company
    description: 'This brand''s sales over all sales across website'
    value_format: '#.0000\%'
    type: number
    sql: 100.0 *  ${total_sale_price_this_brand}*1.0 / nullif(${total_sale_price},0)
   
  - measure: share_of_wallet_within_company
    description: 'This item sales over all sales across website'
    value_format: '#.0000\%'
    type: number
    sql: 100.0 *  ${total_sale_price_this_item}*1.0 / nullif(${total_sale_price},0)
