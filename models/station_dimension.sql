WITH BIKE as (

select
distinct
START_STATIOn_ID as station_id,
start_station_name as station_name,
START_LAT as station_lat,
START_LNG as start_station_lng

from {{ source('demo','biketable') }}

where RIDE_ID != 'ride_id'

)

select
*
from BIKE