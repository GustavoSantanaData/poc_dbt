{{
    config(
        materialized='incremental',
        incremental_strategy='append',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

with src as (
    select
        id as id_evento,
        guia_id as id_guia,
        dt_evento,
        upper(trim(status_anterior)) as status_anterior,
        upper(trim(status_novo)) as status_novo,
        lower(trim(usuario)) as usuario,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_eventos_guia') }}
    where id is not null
      and guia_id is not null
)

select * from src
{% if is_incremental() %}
where id_evento > (select coalesce(max(id_evento), 0) from {{ this }})
{% endif %}
