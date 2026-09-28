{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id_procedimento',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

with src as (
    select
        id as id_procedimento,
        regexp_replace(codigo_tuss, '[^0-9]', '') as codigo_tuss,
        {{ title_case('trim(nome)') }} as nome_procedimento,
        {{ title_case('trim(grupo)') }} as grupo_procedimento,
        trim(porte) as porte,
        exige_autorizacao as fl_exige_autorizacao,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_procedimentos') }}
    where id is not null
)

select * from src
{% if is_incremental() %}
where updated_at > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
