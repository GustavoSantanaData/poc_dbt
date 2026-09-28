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
        id as id_pedido,
        beneficiario_id as id_beneficiario,
        tipo_exame_id as id_tipo_exame,
        dt_pedido,
        {{ title_case('trim(medico_solicitante)') }} as medico_solicitante,
        upper(trim(crm)) as crm,
        {{ title_case('trim(unidade)') }} as unidade,
        upper(trim(status)) as status_pedido,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_pedidos_exame') }}
    where id is not null
      and beneficiario_id is not null
)

select * from src
{% if is_incremental() %}
where id_pedido > (select coalesce(max(id_pedido), 0) from {{ this }})
{% endif %}
