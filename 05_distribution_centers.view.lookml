- view: distribution_centers
  derived_table:
    sortkeys: [id]
    distkey: id
    sql_trigger_value: SELECT DATE(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', GETDATE()))
    sql: |
      
      SELECT 1 AS id, 'Memphis' AS name, 35.1174 AS latitude, -89.9711 AS longitude UNION ALL
      SELECT 2 AS id, 'Chicago' AS name, 41.8369 AS latitude, -87.6847 AS longitude UNION ALL
      SELECT 3 AS id, 'Houston' AS name, 29.7604 AS latitude, -95.3698 AS longitude UNION ALL
      SELECT 4 AS id, 'Los Angeles' AS name, 34.0500 AS latitude, -118.250 AS longitude UNION ALL
      SELECT 5 AS id, 'New Orleans' AS name, 29.9500 AS latitude, -90.0667 AS longitude UNION ALL
      SELECT 6 AS id, 'Port Authority of New York/New Jersey' AS name, 40.6340 AS latitude, -73.7834 AS longitude UNION ALL
      SELECT 7 AS id, 'Philadelphia' AS name, 39.9500 AS latitude, -75.1667 AS longitude UNION ALL
      SELECT 8 AS id, 'Mobile' AS name, 30.6944 AS latitude, -88.0431 AS longitude UNION ALL
      SELECT 9 AS id, 'Charleston' AS name, 32.7833 AS latitude, -79.9333 AS longitude UNION ALL
      SELECT 10 AS id, 'Savannah' AS name, 32.0167 AS latitude, -81.1167 AS longitude

  fields:
  - dimension: location
    type: location
    sql_latitude: ${TABLE}.latitude
    sql_longitude: ${TABLE}.longitude
    
  - dimension: id
    type: number
    primary_key: true
    
  - dimension: name
    