{{
    config(
        materialized='table'
    )
}}

select
    b.id_beneficiario,
    b.carteirinha,
    b.cpf,
    b.nome_beneficiario,
    b.dt_nascimento,
    b.idade,
    b.sexo,
    b.status_beneficiario,
    b.dt_adesao,
    b.municipio,
    b.uf,
    p.id_plano,
    p.codigo_plano,
    p.nome_plano,
    p.tipo_contratacao,
    p.acomodacao,
    p.fl_cobertura_odonto,
    b.updated_at
from {{ ref('prata_beneficiarios') }} b
left join {{ ref('prata_planos') }} p
    on b.id_plano = p.id_plano
