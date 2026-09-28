{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id_programa',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

with src as (
    select
        id as id_programa,
        upper(trim(codigo)) as codigo_programa,
        {{ title_case('trim(nome)') }} as nome_programa,
        {{ title_case('trim(tipo)') }} as tipo_programa,
        trim(descricao) as descricao,
        ativo as fl_ativo,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_programas_cuidado') }}
    where id is not null
)

select * from src
{% if is_incremental() %}
where updated_at > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
