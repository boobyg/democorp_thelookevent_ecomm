- view: countries
  sql_table_name: logs.countries
  fields:

  - dimension: country_code_2_letter
    hidden: true
    sql: ${TABLE}.iso_3166_2

  - dimension: country_code
    sql: ${TABLE}.iso_3166_3

  - dimension: country_name
    sql: ${TABLE}.name
