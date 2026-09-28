{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id_plano',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

with src as (
    select
        id as id_plano,
        upper(trim(codigo)) as codigo_plano,
        {{ title_case('trim(nome)') }} as nome_plano,
        {{ title_case('trim(tipo_contratacao)') }} as tipo_contratacao,
        {{ title_case('trim(acomodacao)') }} as acomodacao,
        cobertura_odonto as fl_cobertura_odonto,
        ativo as fl_ativo,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_planos') }}
    where id is not null
)

select * from src
{% if is_incremental() %}
where updated_at > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
