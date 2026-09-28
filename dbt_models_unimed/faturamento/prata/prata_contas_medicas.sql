{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id_conta',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

with src as (
    select
        id as id_conta,
        trim(numero_conta) as numero_conta,
        guia_id as id_guia,
        prestador_id as id_prestador,
        competencia,
        dt_emissao,
        cast(valor_apresentado as decimal(14, 2)) as valor_apresentado,
        cast(valor_glosado as decimal(14, 2)) as valor_glosado,
        cast(valor_pago as decimal(14, 2)) as valor_pago,
        upper(trim(status)) as status_conta,
        case
            when valor_apresentado = 0 then 0
            else round(valor_glosado / valor_apresentado, 4)
        end as tx_glosa,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_contas_medicas') }}
    where id is not null
      and numero_conta is not null
)

select * from src
{% if is_incremental() %}
where updated_at > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
