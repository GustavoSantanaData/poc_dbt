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
        id as id_acompanhamento,
        vinculo_id as id_vinculo,
        dt_contato,
        upper(trim(canal)) as canal,
        {{ title_case('trim(profissional)') }} as profissional,
        {{ title_case('trim(especialidade)') }} as especialidade,
        upper(trim(desfecho)) as desfecho,
        trim(observacao) as observacao,
        case when upper(trim(desfecho)) = 'ALERTA' then true else false end as fl_alerta,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_acompanhamentos') }}
    where id is not null
      and vinculo_id is not null
)

select * from src
{% if is_incremental() %}
where id_acompanhamento > (select coalesce(max(id_acompanhamento), 0) from {{ this }})
{% endif %}
