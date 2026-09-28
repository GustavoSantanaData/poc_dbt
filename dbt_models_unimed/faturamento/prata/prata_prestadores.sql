{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id_prestador',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

with src as (
    select
        id as id_prestador,
        regexp_replace(cnpj, '[^0-9]', '') as cnpj,
        {{ title_case('trim(razao_social)') }} as razao_social,
        {{ title_case('trim(tipo)') }} as tipo_prestador,
        {{ title_case('trim(municipio)') }} as municipio,
        upper(trim(uf)) as uf,
        ativo as fl_ativo,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_prestadores') }}
    where id is not null
)

select * from src
{% if is_incremental() %}
where updated_at > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
