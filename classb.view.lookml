- view: classb
  sql_table_name: logs.classb
  fields:

  - dimension: classb
    primary_key: true
    hidden: true
    sql: ${TABLE}.classb

  - dimension: country
    hidden: true
    sql: ${TABLE}.country


