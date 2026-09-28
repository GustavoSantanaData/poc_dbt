select
    id,
    beneficiario_id,
    tipo_exame_id,
    dt_pedido,
    medico_solicitante,
    crm,
    unidade,
    status,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('resultados_exames', 'pedidos_exame') }}
