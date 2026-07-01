WITH BIKE AS (
    SELECT
        DISTINCT
        START_STATION_ID AS station_id,
        start_station_name AS station_name,
        START_LAT AS station_lat,
        START_LNG AS start_station_lng
    FROM {{ source('demo','biketable') }}
    WHERE RIDE_ID != 'ride_id'
)
SELECT * FROM BIKE