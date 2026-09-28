select
    id,
    beneficiario_id,
    programa_id,
    dt_inicio,
    dt_fim,
    status,
    risco,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('cuidado_integrado', 'vinculos_programa') }}
