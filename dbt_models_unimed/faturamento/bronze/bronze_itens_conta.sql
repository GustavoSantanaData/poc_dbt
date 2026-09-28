select
    id,
    conta_id,
    procedimento_id,
    descricao,
    qtd,
    valor_unitario,
    valor_total,
    glosa_flag,
    motivo_glosa,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('faturamento', 'itens_conta') }}
