{{
    config(
        materialized='table'
    )
}}

select
    b.id_beneficiario,
    b.nome_beneficiario,
    b.idade,
    b.sexo,
    b.uf,
    b.municipio,
    b.status_beneficiario,
    pl.nome_plano,
    count(distinct v.id_programa) as qtd_programas,
    count(distinct case when v.fl_vinculo_vigente then v.id_programa end) as qtd_programas_ativos,
    max(
        case v.classificacao_risco
            when 'ALTO' then 3
            when 'MEDIO' then 2
            when 'BAIXO' then 1
            else 0
        end
    ) as nivel_risco_num,
    case max(
        case v.classificacao_risco
            when 'ALTO' then 3
            when 'MEDIO' then 2
            when 'BAIXO' then 1
            else 0
        end
    )
        when 3 then 'ALTO'
        when 2 then 'MEDIO'
        when 1 then 'BAIXO'
        else null
    end as maior_risco,
    count(a.id_acompanhamento) as qtd_acompanhamentos,
    count(case when a.fl_alerta then 1 end) as qtd_alertas,
    max(a.dt_contato) as dt_ultimo_contato,
    date_diff('day', max(a.dt_contato), current_date) as dias_sem_contato
from {{ ref('prata_beneficiarios') }} b
left join {{ ref('prata_planos') }} pl
    on b.id_plano = pl.id_plano
left join {{ ref('prata_vinculos_programa') }} v
    on b.id_beneficiario = v.id_beneficiario
left join {{ ref('prata_acompanhamentos') }} a
    on v.id_vinculo = a.id_vinculo
where b.status_beneficiario = 'ATIVO'
group by
    b.id_beneficiario,
    b.nome_beneficiario,
    b.idade,
    b.sexo,
    b.uf,
    b.municipio,
    b.status_beneficiario,
    pl.nome_plano
