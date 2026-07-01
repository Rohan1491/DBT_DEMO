{{ config(
    materialized = 'table'
) }}

WITH date_spine AS (

    SELECT
        DATEADD(DAY, SEQ4(), '2020-01-01'::DATE) AS date_day
    FROM {{ ref('Stage_bike') }} 
),

date_dimension AS (

    SELECT

        date_day                                     AS full_date,
        DAY(date_day)                                AS day_of_month,      -- 1–31
        DAYOFWEEK(date_day)                          AS day_of_week,       -- 0=Sun … 6=Sat (Snowflake default)
        DAYOFWEEKISO(date_day)                       AS day_of_week_iso,   -- 1=Mon … 7=Sun
        DAYOFYEAR(date_day)                          AS day_of_year,       -- 1–366
        TO_CHAR(date_day, 'Dy')                      AS day_name_short,    -- 'Mon'
        WEEKOFYEAR(date_day)                         AS week_of_year,      -- 1–53
        WEEKISO(date_day)                            AS week_of_year_iso,  -- ISO-8601
        DATE_TRUNC('WEEK', date_day)                 AS week_start_date,
        DATEADD(DAY, 6, DATE_TRUNC('WEEK', date_day)) AS week_end_date,
        MONTH(date_day)                              AS month_number,      -- 1–12
        TO_CHAR(date_day, 'Mon')                     AS month_name_short,  -- 'Jan'
        DATE_TRUNC('MONTH', date_day)                AS month_start_date,
        LAST_DAY(date_day)                           AS month_end_date,

        -- ── Boolean flags ─────────────────────────────────────────────────────
        CASE WHEN DAYOFWEEK(date_day) IN (0, 6) THEN TRUE ELSE FALSE END
                                                     AS is_weekend,
        CASE WHEN DAYOFWEEK(date_day) IN (0, 6) THEN FALSE ELSE TRUE END
                                                     AS is_weekday,
        CASE WHEN date_day = LAST_DAY(date_day) THEN TRUE ELSE FALSE END
                                                     AS is_last_day_of_month,

        -- ── Formatted display strings ─────────────────────────────────────────
        TO_CHAR(date_day, 'YYYY-MM-DD')             AS date_iso,          -- '2024-06-15'
        TO_CHAR(date_day, 'MM/DD/YYYY')             AS date_us,           -- '06/15/2024'
        TO_CHAR(date_day, 'YYYY') || '-' || TO_CHAR(date_day, 'MM')
                                                     AS year_month,        -- '2024-06'
        TO_CHAR(date_day, 'YYYY') || '-Q' || QUARTER(date_day)
                                                     AS year_quarter,       -- '2024-Q2'
    {{get_season('date_day')}}  as Season

    FROM date_spine

)

SELECT * FROM date_dimension
ORDER BY full_date