WITH date_spine AS (

    SELECT
        DATEADD(DAY, SEQ4(), '2020-01-01'::DATE) AS date_day
    FROM {{source('demo', 'biketable') }} where ride_id <> 'ride_id'
),

date_dimension AS (

    SELECT

        -- ── Surrogate & natural keys ──────────────────────────────────────────
        TO_CHAR(date_day, 'YYYYMMDD')::INT          AS date_key,          -- e.g. 20240615
        date_day                                     AS full_date,

        -- ── Day-level attributes ──────────────────────────────────────────────
        DAY(date_day)                                AS day_of_month,      -- 1–31
        DAYOFWEEK(date_day)                          AS day_of_week,       -- 0=Sun … 6=Sat (Snowflake default)
        DAYOFWEEKISO(date_day)                       AS day_of_week_iso,   -- 1=Mon … 7=Sun
        DAYOFYEAR(date_day)                          AS day_of_year,       -- 1–366
        TO_CHAR(date_day, 'Day')                     AS day_name,          -- 'Monday'
        TO_CHAR(date_day, 'Dy')                      AS day_name_short,    -- 'Mon'

        -- ── Week-level attributes ─────────────────────────────────────────────
        WEEKOFYEAR(date_day)                         AS week_of_year,      -- 1–53
        WEEKISO(date_day)                            AS week_of_year_iso,  -- ISO-8601
        DATE_TRUNC('WEEK', date_day)                 AS week_start_date,
        DATEADD(DAY, 6, DATE_TRUNC('WEEK', date_day)) AS week_end_date,

        -- ── Month-level attributes ────────────────────────────────────────────
        MONTH(date_day)                              AS month_number,      -- 1–12
        TO_CHAR(date_day, 'Month')                   AS month_name,        -- 'January'
        TO_CHAR(date_day, 'Mon')                     AS month_name_short,  -- 'Jan'
        DATE_TRUNC('MONTH', date_day)                AS month_start_date,
        LAST_DAY(date_day)                           AS month_end_date,

        -- ── Quarter-level attributes ──────────────────────────────────────────
        QUARTER(date_day)                            AS quarter_number,    -- 1–4
        'Q' || QUARTER(date_day)                     AS quarter_name,      -- 'Q1'
        DATE_TRUNC('QUARTER', date_day)              AS quarter_start_date,
        DATEADD(DAY, -1,
            DATEADD(MONTH, 3,
                DATE_TRUNC('QUARTER', date_day)))    AS quarter_end_date,

        -- ── Year-level attributes ─────────────────────────────────────────────
        YEAR(date_day)                               AS year_number,
        YEAROFWEEKISO(date_day)                      AS year_iso,          -- ISO week-year
        DATE_TRUNC('YEAR', date_day)                 AS year_start_date,
        DATEADD(DAY, -1,
            DATEADD(YEAR, 1,
                DATE_TRUNC('YEAR', date_day)))       AS year_end_date,

        -- ── Fiscal year (April start — adjust as needed) ──────────────────────
        CASE
            WHEN MONTH(date_day) >= 4
            THEN YEAR(date_day)
            ELSE YEAR(date_day) - 1
        END                                          AS fiscal_year,

        CASE
            WHEN MONTH(date_day) IN (4,5,6)   THEN 1
            WHEN MONTH(date_day) IN (7,8,9)   THEN 2
            WHEN MONTH(date_day) IN (10,11,12) THEN 3
            ELSE                                    4
        END                                          AS fiscal_quarter,

        -- ── Relative / offset flags ───────────────────────────────────────────
        DATEDIFF(DAY,   CURRENT_DATE(), date_day)   AS days_from_today,
        DATEDIFF(WEEK,  CURRENT_DATE(), date_day)   AS weeks_from_today,
        DATEDIFF(MONTH, CURRENT_DATE(), date_day)   AS months_from_today,

        -- ── Boolean flags ─────────────────────────────────────────────────────
        CASE WHEN DAYOFWEEK(date_day) IN (0, 6) THEN TRUE ELSE FALSE END
                                                     AS is_weekend,
        CASE WHEN DAYOFWEEK(date_day) IN (0, 6) THEN FALSE ELSE TRUE END
                                                     AS is_weekday,
        CASE WHEN date_day = CURRENT_DATE()     THEN TRUE ELSE FALSE END
                                                     AS is_today,
        CASE WHEN date_day < CURRENT_DATE()     THEN TRUE ELSE FALSE END
                                                     AS is_past,
        CASE WHEN date_day = LAST_DAY(date_day) THEN TRUE ELSE FALSE END
                                                     AS is_last_day_of_month,

        -- ── Formatted display strings ─────────────────────────────────────────
        TO_CHAR(date_day, 'YYYY-MM-DD')             AS date_iso,          -- '2024-06-15'
        TO_CHAR(date_day, 'MM/DD/YYYY')             AS date_us,           -- '06/15/2024'
        TO_CHAR(date_day, 'YYYY') || '-' || TO_CHAR(date_day, 'MM')
                                                     AS year_month,        -- '2024-06'
        TO_CHAR(date_day, 'YYYY') || '-Q' || QUARTER(date_day)
                                                     AS year_quarter,        -- '2024-Q2'
    {{get_season('date_day')}}  as Season

    FROM date_spine

)

SELECT * FROM date_dimension
ORDER BY date_key