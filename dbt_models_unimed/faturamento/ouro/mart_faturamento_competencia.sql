{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='sk_competencia_prestador',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

select
    c.competencia || '-' || cast(p.id_prestador as varchar) as sk_competencia_prestador,
    c.competencia,
    p.id_prestador,
    p.razao_social,
    p.tipo_prestador,
    p.uf as uf_prestador,
    count(*) as qtd_contas,
    sum(c.valor_apresentado) as valor_apresentado,
    sum(c.valor_glosado) as valor_glosado,
    sum(c.valor_pago) as valor_pago,
    round(sum(c.valor_glosado) / nullif(sum(c.valor_apresentado), 0), 4) as tx_glosa,
    count(case when c.status_conta = 'PAGA' then 1 end) as qtd_contas_pagas,
    max(c.updated_at) as updated_at
from {{ ref('prata_contas_medicas') }} c
inner join {{ ref('prata_prestadores') }} p
    on c.id_prestador = p.id_prestador
group by
    c.competencia,
    p.id_prestador,
    p.razao_social,
    p.tipo_prestador,
    p.uf
{% if is_incremental() %}
having max(c.updated_at) > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
