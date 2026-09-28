-- ============================================================
-- Cuidado integrado
-- ============================================================
CREATE TABLE IF NOT EXISTS cuidado_integrado.planos (
    id              INTEGER PRIMARY KEY,
    codigo          VARCHAR(20) NOT NULL,
    nome            VARCHAR(120) NOT NULL,
    tipo_contratacao VARCHAR(30) NOT NULL,
    acomodacao      VARCHAR(30) NOT NULL,
    cobertura_odonto BOOLEAN NOT NULL DEFAULT FALSE,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cuidado_integrado.beneficiarios (
    id              INTEGER PRIMARY KEY,
    carteirinha     VARCHAR(20) NOT NULL,
    cpf             VARCHAR(14) NOT NULL,
    nome            VARCHAR(150) NOT NULL,
    dt_nascimento   DATE NOT NULL,
    sexo            VARCHAR(20) NOT NULL,
    plano_id        INTEGER NOT NULL REFERENCES cuidado_integrado.planos (id),
    status          VARCHAR(20) NOT NULL,
    dt_adesao       DATE NOT NULL,
    municipio       VARCHAR(80) NOT NULL,
    uf              CHAR(2) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cuidado_integrado.programas_cuidado (
    id              INTEGER PRIMARY KEY,
    codigo          VARCHAR(20) NOT NULL,
    nome            VARCHAR(120) NOT NULL,
    tipo            VARCHAR(40) NOT NULL,
    descricao       TEXT,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cuidado_integrado.vinculos_programa (
    id              INTEGER PRIMARY KEY,
    beneficiario_id INTEGER NOT NULL REFERENCES cuidado_integrado.beneficiarios (id),
    programa_id     INTEGER NOT NULL REFERENCES cuidado_integrado.programas_cuidado (id),
    dt_inicio       DATE NOT NULL,
    dt_fim          DATE,
    status          VARCHAR(20) NOT NULL,
    risco           VARCHAR(20) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS cuidado_integrado.acompanhamentos (
    id              INTEGER PRIMARY KEY,
    vinculo_id      INTEGER NOT NULL REFERENCES cuidado_integrado.vinculos_programa (id),
    dt_contato      TIMESTAMP NOT NULL,
    canal           VARCHAR(30) NOT NULL,
    profissional    VARCHAR(120) NOT NULL,
    especialidade   VARCHAR(80) NOT NULL,
    desfecho        VARCHAR(40) NOT NULL,
    observacao      TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Resultados de exames
-- ============================================================
CREATE TABLE IF NOT EXISTS resultados_exames.tipos_exame (
    id              INTEGER PRIMARY KEY,
    codigo_tuss     VARCHAR(20) NOT NULL,
    nome            VARCHAR(120) NOT NULL,
    especialidade   VARCHAR(80) NOT NULL,
    material        VARCHAR(60),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS resultados_exames.pedidos_exame (
    id                  INTEGER PRIMARY KEY,
    beneficiario_id     INTEGER NOT NULL REFERENCES cuidado_integrado.beneficiarios (id),
    tipo_exame_id       INTEGER NOT NULL REFERENCES resultados_exames.tipos_exame (id),
    dt_pedido           DATE NOT NULL,
    medico_solicitante  VARCHAR(120) NOT NULL,
    crm                 VARCHAR(20) NOT NULL,
    unidade             VARCHAR(80) NOT NULL,
    status              VARCHAR(20) NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS resultados_exames.resultados_exame (
    id                      INTEGER PRIMARY KEY,
    pedido_id               INTEGER NOT NULL REFERENCES resultados_exames.pedidos_exame (id),
    dt_liberacao            TIMESTAMP NOT NULL,
    valor_numerico          NUMERIC(12, 3),
    unidade_medida          VARCHAR(20),
    valor_referencia_min    NUMERIC(12, 3),
    valor_referencia_max    NUMERIC(12, 3),
    valor_texto             VARCHAR(200),
    flag_alterado           BOOLEAN NOT NULL DEFAULT FALSE,
    laboratorio             VARCHAR(80) NOT NULL,
    created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Autorizacoes
-- ============================================================
CREATE TABLE IF NOT EXISTS autorizacoes.procedimentos (
    id                  INTEGER PRIMARY KEY,
    codigo_tuss         VARCHAR(20) NOT NULL,
    nome                VARCHAR(160) NOT NULL,
    grupo               VARCHAR(80) NOT NULL,
    porte               VARCHAR(10),
    exige_autorizacao   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS autorizacoes.guias_autorizacao (
    id                  INTEGER PRIMARY KEY,
    numero_guia         VARCHAR(20) NOT NULL,
    beneficiario_id     INTEGER NOT NULL REFERENCES cuidado_integrado.beneficiarios (id),
    procedimento_id     INTEGER NOT NULL REFERENCES autorizacoes.procedimentos (id),
    dt_solicitacao      DATE NOT NULL,
    dt_autorizacao      DATE,
    dt_validade         DATE,
    status              VARCHAR(30) NOT NULL,
    senha               VARCHAR(20),
    qtd_solicitada      INTEGER NOT NULL,
    qtd_autorizada      INTEGER,
    cid                 VARCHAR(10),
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS autorizacoes.eventos_guia (
    id                  INTEGER PRIMARY KEY,
    guia_id             INTEGER NOT NULL REFERENCES autorizacoes.guias_autorizacao (id),
    dt_evento           TIMESTAMP NOT NULL,
    status_anterior     VARCHAR(30),
    status_novo         VARCHAR(30) NOT NULL,
    usuario             VARCHAR(80) NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Faturamento
-- ============================================================
CREATE TABLE IF NOT EXISTS faturamento.prestadores (
    id              INTEGER PRIMARY KEY,
    cnpj            VARCHAR(18) NOT NULL,
    razao_social    VARCHAR(160) NOT NULL,
    tipo            VARCHAR(40) NOT NULL,
    municipio       VARCHAR(80) NOT NULL,
    uf              CHAR(2) NOT NULL,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS faturamento.contas_medicas (
    id                  INTEGER PRIMARY KEY,
    numero_conta        VARCHAR(20) NOT NULL,
    guia_id             INTEGER REFERENCES autorizacoes.guias_autorizacao (id),
    prestador_id        INTEGER NOT NULL REFERENCES faturamento.prestadores (id),
    competencia         CHAR(7) NOT NULL,
    dt_emissao          DATE NOT NULL,
    valor_apresentado   NUMERIC(14, 2) NOT NULL,
    valor_glosado       NUMERIC(14, 2) NOT NULL DEFAULT 0,
    valor_pago          NUMERIC(14, 2) NOT NULL DEFAULT 0,
    status              VARCHAR(30) NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS faturamento.itens_conta (
    id                  INTEGER PRIMARY KEY,
    conta_id            INTEGER NOT NULL REFERENCES faturamento.contas_medicas (id),
    procedimento_id     INTEGER NOT NULL REFERENCES autorizacoes.procedimentos (id),
    descricao           VARCHAR(160) NOT NULL,
    qtd                 INTEGER NOT NULL,
    valor_unitario      NUMERIC(12, 2) NOT NULL,
    valor_total         NUMERIC(14, 2) NOT NULL,
    glosa_flag          BOOLEAN NOT NULL DEFAULT FALSE,
    motivo_glosa        VARCHAR(120),
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);
