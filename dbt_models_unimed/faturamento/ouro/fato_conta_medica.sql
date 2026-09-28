{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id_conta',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

select
    c.id_conta,
    c.numero_conta,
    c.competencia,
    c.dt_emissao,
    c.valor_apresentado,
    c.valor_glosado,
    c.valor_pago,
    c.tx_glosa,
    c.status_conta,
    p.id_prestador,
    p.razao_social,
    p.tipo_prestador,
    p.uf as uf_prestador,
    g.numero_guia,
    g.status_guia,
    b.id_beneficiario,
    b.nome_beneficiario,
    c.updated_at
from {{ ref('prata_contas_medicas') }} c
inner join {{ ref('prata_prestadores') }} p
    on c.id_prestador = p.id_prestador
left join {{ ref('prata_guias_autorizacao') }} g
    on c.id_guia = g.id_guia
left join {{ ref('prata_beneficiarios') }} b
    on g.id_beneficiario = b.id_beneficiario
{% if is_incremental() %}
where c.updated_at > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
