{% macro get_season(x) %}

CASE WHEN MONTH({{x}}) in (12,1,2)
THEN 'WINTER'
WHEN MONTH({{x}})  in (3,4,5)
THEN 'SPRING'
WHEN MONTH({{x}}) in (6,7,8)
THEN 'SUMMER'
ELSE 'AUTUMN'
END

{% endmacro %}