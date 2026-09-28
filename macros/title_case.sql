{% macro title_case(expr) %}
regexp_replace(lower(cast({{ expr }} as varchar)), '(\w)(\w*)', x -> upper(x[1]) || lower(x[2]))
{% endmacro %}
