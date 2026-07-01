{{ config(
    materialized = 'table'
) }}

with bike as (
    SELECT 
        ride_id ,
        to_timestamp(started_at) as started_at,
        to_timestamp(ended_at) as ended_at ,
        start_station_name ,
        start_station_id ,
        end_station_name ,
        end_station_id ,
        start_lat ,
        start_lng ,
        end_lat ,
        end_lng ,
        member_casual
    from {{ source('demo', 'biketable') }}
    where ride_id != 'bikeid'
)
select * from bike