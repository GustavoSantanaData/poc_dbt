select
    id,
    cnpj,
    razao_social,
    tipo,
    municipio,
    uf,
    ativo,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('faturamento', 'prestadores') }}
