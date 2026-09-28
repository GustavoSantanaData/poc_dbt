select
    id,
    codigo,
    nome,
    tipo,
    descricao,
    ativo,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('cuidado_integrado', 'programas_cuidado') }}
