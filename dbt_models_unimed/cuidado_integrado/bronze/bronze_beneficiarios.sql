select
    id,
    carteirinha,
    cpf,
    nome,
    dt_nascimento,
    sexo,
    plano_id,
    status,
    dt_adesao,
    municipio,
    uf,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('cuidado_integrado', 'beneficiarios') }}
