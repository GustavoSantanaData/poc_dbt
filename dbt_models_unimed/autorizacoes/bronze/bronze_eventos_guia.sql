select
    id,
    guia_id,
    dt_evento,
    status_anterior,
    status_novo,
    usuario,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('autorizacoes', 'eventos_guia') }}
