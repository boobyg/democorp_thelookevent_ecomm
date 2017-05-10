explore: events_aa {}
view: events_aa {
  derived_table:
  {sql:
    SELECT
      *
    FROM
      {% if event_date._in_query %}
    ${events_by_date.SQL_TABLE_NAME}
      {% elsif event_week._in_query %}
    ${events_by_week.SQL_TABLE_NAME}
      {% else event_year._in_query %}
    ${events_by_year.SQL_TABLE_NAME}
      {% endif %}
      ;;
      }
dimension_group: event {
  type: time
  convert_tz: no
  timeframes: [date, week, year]
  sql: ${TABLE}.created ;;
}

dimension: events {
  sql: ${TABLE}.events ;;
}

}

view: events_by_year {
  derived_table: {
    sql: SELECT
        DATE_PART(year, events.created_at )::integer AS created,
        COUNT(*) AS events
      FROM events  AS events
      GROUP BY 1

       ;;
  }

  measure: count {
    type: count
  }

  dimension: created {
    type: number
    sql: ${TABLE}.created
  }

  dimension: events {
    type: number
    sql: ${TABLE}.events ;;
  }

}

view: events_by_date {
  derived_table: {
    sql: -- raw sql results do not include filled-in values for 'events.event_date'


            SELECT
              DATE(events.created_at) AS created,
              COUNT(*) AS events
            FROM events  AS events
            GROUP BY 1

             ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: created {
    type: date
    sql: ${TABLE}.created ;;
  }

  dimension: events {
    type: number
    sql: ${TABLE}.events ;;
  }

  set: detail {
    fields: [created, events]
  }
}


view: events_by_week {
  derived_table: {
    sql: SELECT
        TO_CHAR(DATE_TRUNC('week', events.created_at ), 'YYYY-MM-DD') AS created,
        COUNT(*) AS events
      FROM events  AS events
      GROUP BY 1

       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: created {
    type: string
    sql: ${TABLE}.created ;;
  }

  dimension: events {
    type: number
    sql: ${TABLE}.events ;;
  }

  set: detail {
    fields: [created, events]
  }
}
