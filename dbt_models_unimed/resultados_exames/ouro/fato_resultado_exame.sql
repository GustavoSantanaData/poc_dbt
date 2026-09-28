{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='id_resultado',
        on_schema_change='sync_all_columns',
        properties={"format_version": "2"}
    )
}}

select
    r.id_resultado,
    r.dt_liberacao,
    r.valor_numerico,
    r.unidade_medida,
    r.valor_referencia_min,
    r.valor_referencia_max,
    r.valor_texto,
    r.fl_alterado_origem,
    r.fl_fora_referencia,
    r.laboratorio,
    p.id_pedido,
    p.dt_pedido,
    p.status_pedido,
    p.medico_solicitante,
    t.id_tipo_exame,
    t.codigo_tuss,
    t.nome_exame,
    t.especialidade,
    b.id_beneficiario,
    b.nome_beneficiario,
    b.uf,
    r.updated_at
from {{ ref('prata_resultados_exame') }} r
inner join {{ ref('prata_pedidos_exame') }} p
    on r.id_pedido = p.id_pedido
inner join {{ ref('prata_tipos_exame') }} t
    on p.id_tipo_exame = t.id_tipo_exame
inner join {{ ref('prata_beneficiarios') }} b
    on p.id_beneficiario = b.id_beneficiario
{% if is_incremental() %}
where r.updated_at > (select coalesce(max(updated_at), timestamp '1970-01-01 00:00:00') from {{ this }})
{% endif %}
