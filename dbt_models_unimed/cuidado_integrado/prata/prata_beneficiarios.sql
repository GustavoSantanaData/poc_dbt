{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id_beneficiario',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

with src as (
    select
        id as id_beneficiario,
        trim(carteirinha) as carteirinha,
        regexp_replace(cpf, '[^0-9]', '') as cpf,
        {{ title_case('trim(nome)') }} as nome_beneficiario,
        dt_nascimento,
        date_diff('year', dt_nascimento, current_date) as idade,
        case
            when upper(sexo) in ('F', 'FEMININO') then 'F'
            when upper(sexo) in ('M', 'MASCULINO') then 'M'
            else 'NI'
        end as sexo,
        plano_id as id_plano,
        upper(trim(status)) as status_beneficiario,
        dt_adesao,
        {{ title_case('trim(municipio)') }} as municipio,
        upper(trim(uf)) as uf,
        created_at,
        updated_at,
        _ingested_at
    from {{ ref('bronze_beneficiarios') }}
    where id is not null
      and carteirinha is not null
)

select * from src
{% if is_incremental() %}
where updated_at > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
