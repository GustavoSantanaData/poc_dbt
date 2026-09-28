select
    id,
    numero_guia,
    beneficiario_id,
    procedimento_id,
    dt_solicitacao,
    dt_autorizacao,
    dt_validade,
    status,
    senha,
    qtd_solicitada,
    qtd_autorizada,
    cid,
    created_at,
    updated_at,
    {{ ingested_columns() }}
from {{ source('autorizacoes', 'guias_autorizacao') }}
