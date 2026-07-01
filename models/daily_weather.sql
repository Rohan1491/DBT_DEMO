
{{ config(
    materialized = 'table'
) }}

with CTE as (
select 
    date(date) as daily_weather,
    Main as weather,
    temperature,
    pressure,
    humidity,
    cloud_cover_PCT
from {{ source('demo', 'weather') }}
)
select 
    daily_weather, weather, round(avg(temperature),0) as Temp, round(avg(pressure),0) as pressure, round(avg(humidity),1) as humidity, round(avg(cloud_cover_PCT),0) as Cloud_PCT
from cte 
group by daily_weather, weather
qualify row_number() over(partition by daily_weather order by count(weather) desc)= 1

