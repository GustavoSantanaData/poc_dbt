{{
    config(
        materialized='table'
    )
}}

select
    g.status_guia_ajustado as status_guia,
    pr.grupo_procedimento,
    count(*) as qtd_guias,
    avg(g.sla_dias_autorizacao) as sla_medio_dias,
    count(case when g.sla_dias_autorizacao > 2 then 1 end) as qtd_fora_sla,
    sum(g.qtd_solicitada) as qtd_solicitada,
    sum(g.qtd_autorizada) as qtd_autorizada
from {{ ref('prata_guias_autorizacao') }} g
inner join {{ ref('prata_procedimentos') }} pr
    on g.id_procedimento = pr.id_procedimento
group by
    g.status_guia_ajustado,
    pr.grupo_procedimento
