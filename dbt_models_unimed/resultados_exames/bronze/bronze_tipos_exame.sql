select
    id,
    codigo_tuss,
    nome,
    especialidade,
    material,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('resultados_exames', 'tipos_exame') }}
