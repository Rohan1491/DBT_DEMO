WITH TRIPS as (
    select
        RIDE_ID,
        RIDEABLE_TYPE,
        DATE(TO_TIMESTAMP(STARTED_AT)) AS TRIP_DATE,
        START_STATIOn_ID AS START_STATION_ID,
        END_STATION_ID,
        MEMBER_CaSUAL AS MEMBER_CASUAL,
        TIMESTAMPDIFF(SECOND,TO_TIMESTAMP(STARTED_AT),TO_TIMESTAMP(ENDED_AT)) AS TRIP_DURATION_SECONDS
    from {{ source('demo', 'biketable') }}
    where RIDE_ID != 'ride_id'
)
select * from TRIPS
