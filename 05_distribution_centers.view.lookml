- view: distribution_centers
  derived_table:
    sortkeys: [id]
    distkey: id
    sql_trigger_value: SELECT current_date
    sql: |
      SELECT 1 as id, 'Memphis' as name, 35.1174 as latitude, -89.9711 as longitude UNION ALL
      SELECT 2 as id, 'Chicago' as name, 41.8369 as latitude, -87.6847 as longitude UNION ALL
      SELECT 3 as id, 'Houston' as name, 29.7604 as latitude, -95.3698 as longitude UNION ALL
      SELECT 4 as id, 'Los Angeles' as name, 34.0500 as latitude, -118.250 as longitude UNION ALL
      SELECT 5 as id, 'New Orleans' as name, 29.9500 as latitude, -90.0667 as longitude UNION ALL
      SELECT 6 as id, 'Port Authority of New York/New Jersey' as name, 40.6340 as latitude, -73.7834 as longitude UNION ALL
      SELECT 7 as id, 'Philadelphia' as name, 39.9500 as latitude, -75.1667 as longitude UNION ALL
      SELECT 8 as id, 'Mobile' as name, 30.6944 as latitude, -88.0431 as longitude UNION ALL
      SELECT 9 as id, 'Charleston' as name, 32.7833 as latitude, -79.9333 as longitude UNION ALL
      SELECT 10 as id, 'Savannah' as name, 32.0167 as latitude, -81.1167 as longitude

  fields:
  - dimension: location
    type: location
    sql_latitude: ${TABLE}.latitude
    sql_longitude: ${TABLE}.longitude
    
  - dimension: id
    type: int
    primary_key: true
    
  - dimension: name
    

