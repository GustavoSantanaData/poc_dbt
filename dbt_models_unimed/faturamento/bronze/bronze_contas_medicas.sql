select
    id,
    numero_conta,
    guia_id,
    prestador_id,
    competencia,
    dt_emissao,
    valor_apresentado,
    valor_glosado,
    valor_pago,
    status,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('faturamento', 'contas_medicas') }}
