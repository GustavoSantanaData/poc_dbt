select
    id,
    pedido_id,
    dt_liberacao,
    valor_numerico,
    unidade_medida,
    valor_referencia_min,
    valor_referencia_max,
    valor_texto,
    flag_alterado,
    laboratorio,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('resultados_exames', 'resultados_exame') }}
