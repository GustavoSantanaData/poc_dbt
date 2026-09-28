select
    id,
    codigo_tuss,
    nome,
    grupo,
    porte,
    exige_autorizacao,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('autorizacoes', 'procedimentos') }}
