# # kittens for certain demos
# 
- explore: kitten_order_items
  label: 'Order Items (Kittens)'
  hidden: true
  extends: order_items
  joins:
    - join: users
      view_label: 'Kittens'
      from: kitten_users
    
- view: kitten_users
  extends: users
  fields:
  - dimension: portrait
    label: 'Kitten Portrait'
    sql: GREATEST(MOD(${id}*97,867),MOD(${id}*31,881),MOD(${id}*72,893))
    type: number
    html: |
      <img height=80 width=80 src="http://placekitten.com/g/{{ value }}/{{ value }}">

  - dimension: name
    label: 'Kitten Name'
    sql: ${first_name} || ' ' || ${TABLE}.last_name

  - dimension: first_name
    label: 'Kitten First Name'
    sql_case:
      Bella: MOD(${id},24) = 23
      Bandit: MOD(${id},24) = 22
      Tigger: MOD(${id},24) = 21
      Boots: MOD(${id},24) = 20
      Chloe: MOD(${id},24) = 19
      Maggie: MOD(${id},24) = 18
      Pumpkin: MOD(${id},24) = 17
      Oliver: MOD(${id},24) = 16
      Sammy: MOD(${id},24) = 15
      Shadow: MOD(${id},24) = 14
      Sassy: MOD(${id},24) = 13
      Kitty: MOD(${id},24) = 12
      Snowball: MOD(${id},24) = 11
      Snickers: MOD(${id},24) = 10
      Socks: MOD(${id},24) = 9
      Gizmo: MOD(${id},24) = 8
      Jake: MOD(${id},24) = 7
      Lily: MOD(${id},24) = 6
      Charlie: MOD(${id},24) = 5
      Peanut: MOD(${id},24) = 4
      Zoe: MOD(${id},24) = 3
      Felix: MOD(${id},24) = 2
      Mimi: MOD(${id},24) = 1
      Jasmine: MOD(${id},24) = 0
  
  sets:
    detail: [SUPER*, portrait]

- view: kitten_order_items
  extends: order_items
  sets:
    detail: [SUPER*, users.portrait]