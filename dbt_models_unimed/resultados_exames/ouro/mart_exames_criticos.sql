{{
    config(
        materialized='table'
    )
}}

select
    b.id_beneficiario,
    b.nome_beneficiario,
    b.uf,
    t.nome_exame,
    t.especialidade,
    r.dt_liberacao,
    r.valor_numerico,
    r.unidade_medida,
    r.valor_referencia_min,
    r.valor_referencia_max,
    r.laboratorio,
    r.fl_fora_referencia,
    p.medico_solicitante
from {{ ref('prata_resultados_exame') }} r
inner join {{ ref('prata_pedidos_exame') }} p
    on r.id_pedido = p.id_pedido
inner join {{ ref('prata_tipos_exame') }} t
    on p.id_tipo_exame = t.id_tipo_exame
inner join {{ ref('prata_beneficiarios') }} b
    on p.id_beneficiario = b.id_beneficiario
where r.fl_fora_referencia = true
