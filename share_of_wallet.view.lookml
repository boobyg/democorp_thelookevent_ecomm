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
      order_items.comparison: '(1)%'

  - measure: total_sale_price_this_brand
    type: sum
    sql: ${sale_price}
    filters:
      order_items.comparison: '(2)%,(1)%'
    
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
