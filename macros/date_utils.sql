{% macro function1(x)%}
case when to_timestamp({{x}}) < current_date then 'Past'
else 'Future' end
{% endmacro %}