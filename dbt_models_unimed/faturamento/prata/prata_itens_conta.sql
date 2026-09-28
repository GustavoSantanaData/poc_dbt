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
        id as id_item,
        conta_id as id_conta,
        procedimento_id as id_procedimento,
        trim(descricao) as descricao_item,
        qtd,
        cast(valor_unitario as decimal(12, 2)) as valor_unitario,
        cast(valor_total as decimal(14, 2)) as valor_total,
        glosa_flag as fl_glosa,
        trim(motivo_glosa) as motivo_glosa,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_itens_conta') }}
    where id is not null
      and conta_id is not null
)

select * from src
{% if is_incremental() %}
where id_item > (select coalesce(max(id_item), 0) from {{ this }})
{% endif %}
