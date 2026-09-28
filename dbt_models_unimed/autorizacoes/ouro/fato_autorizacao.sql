{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id_guia',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

select
    g.id_guia,
    g.numero_guia,
    g.dt_solicitacao,
    g.dt_autorizacao,
    g.dt_validade,
    g.status_guia,
    g.status_guia_ajustado,
    g.senha,
    g.qtd_solicitada,
    g.qtd_autorizada,
    g.cid,
    g.sla_dias_autorizacao,
    pr.id_procedimento,
    pr.codigo_tuss,
    pr.nome_procedimento,
    pr.grupo_procedimento,
    pr.fl_exige_autorizacao,
    b.id_beneficiario,
    b.nome_beneficiario,
    b.uf,
    g.updated_at
from {{ ref('prata_guias_autorizacao') }} g
inner join {{ ref('prata_procedimentos') }} pr
    on g.id_procedimento = pr.id_procedimento
inner join {{ ref('prata_beneficiarios') }} b
    on g.id_beneficiario = b.id_beneficiario
{% if is_incremental() %}
where g.updated_at > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
