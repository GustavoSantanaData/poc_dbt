select
    id,
    codigo,
    nome,
    tipo_contratacao,
    acomodacao,
    cobertura_odonto,
    ativo,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('cuidado_integrado', 'planos') }}
