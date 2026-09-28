{% macro trino__current_timestamp() %}
    current_timestamp(6)
{% endmacro %}

{% macro ingested_columns() %}
    current_timestamp(6) as _ingested_at,
    'postgres_unimed' as _source_system
{% endmacro %}
