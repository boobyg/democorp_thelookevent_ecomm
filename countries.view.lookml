- view: countries
  sql_table_name: logs.countries
  fields:

  - dimension: iso_3166_2
    sql: ${TABLE}.iso_3166_2

  - dimension: iso_3166_3
    sql: ${TABLE}.iso_3166_3

  - dimension: name
    sql: ${TABLE}.name

  - measure: count
    type: count
    drill_fields: [name]

