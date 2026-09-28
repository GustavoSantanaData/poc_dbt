{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id_vinculo',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

with src as (
    select
        id as id_vinculo,
        beneficiario_id as id_beneficiario,
        programa_id as id_programa,
        dt_inicio,
        dt_fim,
        upper(trim(status)) as status_vinculo,
        upper(trim(risco)) as classificacao_risco,
        case when dt_fim is null and upper(trim(status)) = 'ATIVO' then true else false end as fl_vinculo_vigente,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_vinculos_programa') }}
    where id is not null
      and beneficiario_id is not null
      and programa_id is not null
)

select * from src
{% if is_incremental() %}
where updated_at > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
