{{ config(
    materialized = 'table'
) }}

WITH BIKE AS (
    SELECT
        DISTINCT
        START_STATION_ID AS station_id,
        start_station_name AS station_name,
        START_LAT AS station_lat,
        START_LNG AS start_station_lng
    FROM {{ ref('Stage_bike') }}
)
SELECT * FROM BIKE