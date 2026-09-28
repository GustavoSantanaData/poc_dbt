{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id_resultado',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

with src as (
    select
        id as id_resultado,
        pedido_id as id_pedido,
        dt_liberacao,
        valor_numerico,
        trim(unidade_medida) as unidade_medida,
        valor_referencia_min,
        valor_referencia_max,
        trim(valor_texto) as valor_texto,
        flag_alterado as fl_alterado_origem,
        case
            when valor_numerico is not null
                 and valor_referencia_min is not null
                 and valor_numerico < valor_referencia_min then true
            when valor_numerico is not null
                 and valor_referencia_max is not null
                 and valor_numerico > valor_referencia_max then true
            else coalesce(flag_alterado, false)
        end as fl_fora_referencia,
        {{ title_case('trim(laboratorio)') }} as laboratorio,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_resultados_exame') }}
    where id is not null
      and pedido_id is not null
)

select * from src
{% if is_incremental() %}
where updated_at > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
