select
    id,
    vinculo_id,
    dt_contato,
    canal,
    profissional,
    especialidade,
    desfecho,
    observacao,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('cuidado_integrado', 'acompanhamentos') }}
