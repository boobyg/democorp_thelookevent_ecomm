- view: distribution_centers

  fields:
  - dimension: location
    type: location
    sql_latitude: ${TABLE}.latitude
    sql_longitude: ${TABLE}.longitude
    
  - dimension: id
    type: number
    primary_key: true
    sql: ${TABLE}.id
    
  - dimension: name
    sql: ${TABLE}.name
    