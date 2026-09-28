{{
    config(
        materialized='incremental',
        incremental_strategy='append',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

select
    a.id_acompanhamento,
    a.dt_contato,
    a.canal,
    a.profissional,
    a.especialidade,
    a.desfecho,
    a.fl_alerta,
    a.observacao,
    v.id_vinculo,
    v.status_vinculo,
    v.classificacao_risco,
    v.fl_vinculo_vigente,
    p.id_programa,
    p.nome_programa,
    p.tipo_programa,
    b.id_beneficiario,
    b.nome_beneficiario,
    b.uf,
    pl.nome_plano,
    a.updated_at
from {{ ref('prata_acompanhamentos') }} a
inner join {{ ref('prata_vinculos_programa') }} v
    on a.id_vinculo = v.id_vinculo
inner join {{ ref('prata_programas_cuidado') }} p
    on v.id_programa = p.id_programa
inner join {{ ref('prata_beneficiarios') }} b
    on v.id_beneficiario = b.id_beneficiario
left join {{ ref('prata_planos') }} pl
    on b.id_plano = pl.id_plano
{% if is_incremental() %}
where a.id_acompanhamento > (select coalesce(max(id_acompanhamento), 0) from {{ this }})
{% endif %}
