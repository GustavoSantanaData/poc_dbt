{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id_guia',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

with src as (
    select
        id as id_guia,
        trim(numero_guia) as numero_guia,
        beneficiario_id as id_beneficiario,
        procedimento_id as id_procedimento,
        dt_solicitacao,
        dt_autorizacao,
        dt_validade,
        upper(trim(status)) as status_guia,
        trim(senha) as senha,
        qtd_solicitada,
        coalesce(qtd_autorizada, 0) as qtd_autorizada,
        upper(trim(cid)) as cid,
        case
            when dt_autorizacao is not null
            then date_diff('day', dt_solicitacao, dt_autorizacao)
        end as sla_dias_autorizacao,
        case
            when upper(trim(status)) = 'AUTORIZADA'
                 and dt_validade is not null
                 and dt_validade < current_date then 'VENCIDA'
            else upper(trim(status))
        end as status_guia_ajustado,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_guias_autorizacao') }}
    where id is not null
      and numero_guia is not null
)

select * from src
{% if is_incremental() %}
where updated_at > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
