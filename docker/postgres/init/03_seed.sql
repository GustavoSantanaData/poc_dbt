-- Recarrega dados de demonstracao a cada bootstrap
TRUNCATE TABLE
    faturamento.itens_conta,
    faturamento.contas_medicas,
    faturamento.prestadores,
    autorizacoes.eventos_guia,
    autorizacoes.guias_autorizacao,
    autorizacoes.procedimentos,
    resultados_exames.resultados_exame,
    resultados_exames.pedidos_exame,
    resultados_exames.tipos_exame,
    cuidado_integrado.acompanhamentos,
    cuidado_integrado.vinculos_programa,
    cuidado_integrado.programas_cuidado,
    cuidado_integrado.beneficiarios,
    cuidado_integrado.planos
RESTART IDENTITY CASCADE;

INSERT INTO cuidado_integrado.planos
    (id, codigo, nome, tipo_contratacao, acomodacao, cobertura_odonto, ativo, created_at, updated_at)
VALUES
    (1, 'ESS-ENF', 'Unimed Essencial Enfermaria', 'Adesao', 'Enfermaria', FALSE, TRUE, '2024-01-10 08:00:00', '2026-01-10 08:00:00'),
    (2, 'ESS-APT', 'Unimed Essencial Apartamento', 'Adesao', 'Apartamento', FALSE, TRUE, '2024-01-10 08:00:00', '2026-01-10 08:00:00'),
    (3, 'CLA-ENF', 'Unimed Classico Enfermaria', 'Empresarial', 'Enfermaria', TRUE, TRUE, '2024-02-01 08:00:00', '2026-02-01 08:00:00'),
    (4, 'CLA-APT', 'Unimed Classico Apartamento', 'Empresarial', 'Apartamento', TRUE, TRUE, '2024-02-01 08:00:00', '2026-02-01 08:00:00'),
    (5, 'ABS', 'Unimed Absoluto', 'Individual', 'Apartamento', TRUE, TRUE, '2024-03-15 08:00:00', '2026-03-15 08:00:00'),
    (6, 'PLN', 'Unimed Pleno', 'Empresarial', 'Enfermaria', TRUE, FALSE, '2023-11-01 08:00:00', '2025-12-01 08:00:00');

INSERT INTO cuidado_integrado.beneficiarios
    (id, carteirinha, cpf, nome, dt_nascimento, sexo, plano_id, status, dt_adesao, municipio, uf, created_at, updated_at)
VALUES
    (1,  '001234567890001', '12345678901', 'Ana Souza Lima',        '1988-03-12', 'F', 4, 'ATIVO',   '2021-02-10', 'Rio de Janeiro', 'RJ', '2021-02-10 10:00:00', '2026-08-01 10:00:00'),
    (2,  '001234567890002', '23456789012', 'Bruno Oliveira Costa',  '1975-11-02', 'M', 5, 'ATIVO',   '2019-06-01', 'Niteroi',        'RJ', '2019-06-01 10:00:00', '2026-07-15 10:00:00'),
    (3,  '001234567890003', '34567890123', 'Camila Ferreira Dias',  '1992-07-21', 'F', 3, 'ATIVO',   '2022-01-20', 'Sao Paulo',      'SP', '2022-01-20 10:00:00', '2026-06-20 10:00:00'),
    (4,  '001234567890004', '45678901234', 'Diego Martins Rocha',   '1968-01-30', 'M', 4, 'ATIVO',   '2018-09-12', 'Belo Horizonte', 'MG', '2018-09-12 10:00:00', '2026-09-01 10:00:00'),
    (5,  '001234567890005', '56789012345', 'Elisa Mendes Pinto',    '2001-05-08', 'F', 1, 'ATIVO',   '2023-04-03', 'Campinas',       'SP', '2023-04-03 10:00:00', '2026-05-10 10:00:00'),
    (6,  '001234567890006', '67890123456', 'Fabio Araujo Nunes',    '1983-12-19', 'M', 2, 'SUSPENSO','2020-08-18', 'Vitoria',        'ES', '2020-08-18 10:00:00', '2026-04-02 10:00:00'),
    (7,  '001234567890007', '78901234567', 'Gabriela Ribeiro',      '1995-09-14', 'Feminino', 3, 'ATIVO', '2022-11-11', 'Santos',     'SP', '2022-11-11 10:00:00', '2026-08-22 10:00:00'),
    (8,  '001234567890008', '89012345678', 'Henrique Castro Alves', '1959-04-05', 'Masculino', 5, 'ATIVO', '2016-03-01', 'Juiz de Fora', 'MG', '2016-03-01 10:00:00', '2026-09-10 10:00:00'),
    (9,  '001234567890009', '90123456789', 'Isabela Duarte Lopes',  '1986-10-27', 'F', 4, 'ATIVO',   '2021-07-07', 'Curitiba',       'PR', '2021-07-07 10:00:00', '2026-07-07 10:00:00'),
    (10, '001234567890010', '01234567890', 'Joao Pedro Barbosa',    '1990-02-16', 'M', 1, 'CANCELADO','2019-01-15', 'Porto Alegre',  'RS', '2019-01-15 10:00:00', '2026-02-01 10:00:00'),
    (11, '001234567890011', '11234567890', 'Karina Teixeira Gomes', '1979-08-09', 'F', 3, 'ATIVO',   '2020-05-22', 'Goiania',        'GO', '2020-05-22 10:00:00', '2026-08-18 10:00:00'),
    (12, '001234567890012', '12234567890', 'Lucas Henrique Silva',  '1998-06-03', 'M', 2, 'ATIVO',   '2024-01-08', 'Rio de Janeiro', 'RJ', '2024-01-08 10:00:00', '2026-09-05 10:00:00'),
    (13, '001234567890013', '13234567890', 'Mariana Lopes Vieira',  '1972-12-25', 'F', 5, 'ATIVO',   '2017-10-30', 'Sao Paulo',      'SP', '2017-10-30 10:00:00', '2026-06-11 10:00:00'),
    (14, '001234567890014', '14234567890', 'Nelson Faria Campos',   '1964-03-18', 'M', 4, 'ATIVO',   '2015-08-14', 'Uberlandia',     'MG', '2015-08-14 10:00:00', '2026-09-12 10:00:00'),
    (15, '001234567890015', '15234567890', 'Olivia Costa Ramos',    '2003-01-22', 'F', 1, 'ATIVO',   '2025-02-02', 'Niteroi',        'RJ', '2025-02-02 10:00:00', '2026-08-02 10:00:00'),
    (16, '001234567890016', '16234567890', 'Paulo Henrique Mota',   '1981-07-29', 'M', 3, 'ATIVO',   '2019-12-01', 'Campinas',       'SP', '2019-12-01 10:00:00', '2026-07-29 10:00:00'),
    (17, '001234567890017', '17234567890', 'Queila Santos Prado',   '1993-11-11', 'F', 2, 'ATIVO',   '2023-09-19', 'Vitoria',        'ES', '2023-09-19 10:00:00', '2026-09-19 10:00:00'),
    (18, '001234567890018', '18234567890', 'Rafael Nogueira Lima',  '1970-05-06', 'M', 5, 'SUSPENSO','2018-04-24', 'Belo Horizonte', 'MG', '2018-04-24 10:00:00', '2026-03-20 10:00:00'),
    (19, '001234567890019', '19234567890', 'Sofia Albuquerque',     '1989-09-01', 'F', 4, 'ATIVO',   '2021-03-03', 'Rio de Janeiro', 'RJ', '2021-03-03 10:00:00', '2026-09-03 10:00:00'),
    (20, '001234567890020', '20234567890', 'Tiago Mendes Carvalho', '1961-02-14', 'M', 5, 'ATIVO',   '2014-11-20', 'Sao Paulo',      'SP', '2014-11-20 10:00:00', '2026-08-28 10:00:00');

INSERT INTO cuidado_integrado.programas_cuidado
    (id, codigo, nome, tipo, descricao, ativo, created_at, updated_at)
VALUES
    (1, 'CRON-DM',  'Diabetes Melitus',           'Cronico',     'Acompanhamento de beneficiarios com DM1/DM2', TRUE,  '2023-01-01 08:00:00', '2026-01-01 08:00:00'),
    (2, 'CRON-HAS', 'Hipertensao Arterial',       'Cronico',     'Controle pressorico e adesao medicamentosa', TRUE,  '2023-01-01 08:00:00', '2026-01-01 08:00:00'),
    (3, 'MATERNA',  'Gestante de Risco',          'Materno',     'Pre-natal de alto risco', TRUE,                 '2023-03-01 08:00:00', '2026-03-01 08:00:00'),
    (4, 'IDOSO',    'Idoso Fragil',               'Geriatrico',  'Prevencao de quedas e polifarmacia', TRUE,      '2023-04-01 08:00:00', '2026-04-01 08:00:00'),
    (5, 'POS-ALTA', 'Transicao do Cuidado',       'Hospitalar',  'Follow-up pos internacao', TRUE,               '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (6, 'ONCO',     'Oncologia Integrada',        'Oncologico',  'Navegacao do paciente oncologico', FALSE,       '2022-06-01 08:00:00', '2025-12-01 08:00:00');

INSERT INTO cuidado_integrado.vinculos_programa
    (id, beneficiario_id, programa_id, dt_inicio, dt_fim, status, risco, created_at, updated_at)
VALUES
    (1,  1,  1, '2025-01-10', NULL,         'ATIVO',     'ALTO',    '2025-01-10 09:00:00', '2026-08-01 09:00:00'),
    (2,  2,  2, '2024-06-01', NULL,         'ATIVO',     'MEDIO',   '2024-06-01 09:00:00', '2026-07-01 09:00:00'),
    (3,  4,  1, '2024-02-15', NULL,         'ATIVO',     'ALTO',    '2024-02-15 09:00:00', '2026-09-01 09:00:00'),
    (4,  4,  2, '2024-02-15', NULL,         'ATIVO',     'ALTO',    '2024-02-15 09:00:00', '2026-09-01 09:00:00'),
    (5,  8,  4, '2023-05-01', NULL,         'ATIVO',     'ALTO',    '2023-05-01 09:00:00', '2026-09-10 09:00:00'),
    (6,  13, 2, '2024-09-20', NULL,         'ATIVO',     'MEDIO',   '2024-09-20 09:00:00', '2026-06-11 09:00:00'),
    (7,  14, 4, '2023-11-11', NULL,         'ATIVO',     'ALTO',    '2023-11-11 09:00:00', '2026-09-12 09:00:00'),
    (8,  19, 3, '2026-03-01', NULL,         'ATIVO',     'MEDIO',   '2026-03-01 09:00:00', '2026-09-03 09:00:00'),
    (9,  20, 4, '2022-01-10', NULL,         'ATIVO',     'ALTO',    '2022-01-10 09:00:00', '2026-08-28 09:00:00'),
    (10, 3,  1, '2025-07-01', '2026-02-01', 'ENCERRADO', 'BAIXO',   '2025-07-01 09:00:00', '2026-02-01 09:00:00'),
    (11, 11, 5, '2026-05-12', NULL,         'ATIVO',     'MEDIO',   '2026-05-12 09:00:00', '2026-08-18 09:00:00'),
    (12, 16, 2, '2025-03-03', NULL,         'ATIVO',     'BAIXO',   '2025-03-03 09:00:00', '2026-07-29 09:00:00'),
    (13, 7,  3, '2026-01-15', '2026-08-01', 'ENCERRADO', 'BAIXO',   '2026-01-15 09:00:00', '2026-08-01 09:00:00'),
    (14, 18, 1, '2024-10-01', '2026-03-20', 'SUSPENSO',  'ALTO',    '2024-10-01 09:00:00', '2026-03-20 09:00:00'),
    (15, 5,  5, '2026-06-01', NULL,         'ATIVO',     'BAIXO',   '2026-06-01 09:00:00', '2026-06-01 09:00:00');

INSERT INTO cuidado_integrado.acompanhamentos
    (id, vinculo_id, dt_contato, canal, profissional, especialidade, desfecho, observacao, created_at, updated_at)
VALUES
    (1,  1,  '2026-07-02 10:15:00', 'TELEFONE', 'Enf. Paula Reis',     'Enfermagem',     'ORIENTADO',     'Reforco de glicemia capilar', '2026-07-02 10:15:00', '2026-07-02 10:15:00'),
    (2,  1,  '2026-08-04 11:00:00', 'APP',      'Enf. Paula Reis',     'Enfermagem',     'AGENDADO',      'Retorno endocrino', '2026-08-04 11:00:00', '2026-08-04 11:00:00'),
    (3,  2,  '2026-06-10 09:30:00', 'PRESENCIAL','Dr. Carlos Mello',   'Cardiologia',    'ESTAVEL',       'PA controlada', '2026-06-10 09:30:00', '2026-06-10 09:30:00'),
    (4,  3,  '2026-08-12 14:00:00', 'TELEFONE', 'Enf. Joana Pires',    'Enfermagem',     'ALERTA',        'Glicemia de jejum elevada', '2026-08-12 14:00:00', '2026-08-12 14:00:00'),
    (5,  4,  '2026-08-12 14:20:00', 'TELEFONE', 'Enf. Joana Pires',    'Enfermagem',     'ORIENTADO',     'Ajuste de anti-hipertensivo', '2026-08-12 14:20:00', '2026-08-12 14:20:00'),
    (6,  5,  '2026-07-22 16:00:00', 'DOMICILIAR','Fisio. Renata Dias', 'Fisioterapia',   'ESTAVEL',       'Sem queda no periodo', '2026-07-22 16:00:00', '2026-07-22 16:00:00'),
    (7,  5,  '2026-09-05 10:00:00', 'TELEFONE', 'Enf. Marcos Lima',    'Enfermagem',     'ALERTA',        'Relato de tontura', '2026-09-05 10:00:00', '2026-09-05 10:00:00'),
    (8,  8,  '2026-04-18 09:00:00', 'PRESENCIAL','Dra. Helena Costa',  'Obstetricia',    'ORIENTADO',     'Pre-natal em dia', '2026-04-18 09:00:00', '2026-04-18 09:00:00'),
    (9,  8,  '2026-07-20 09:00:00', 'PRESENCIAL','Dra. Helena Costa',  'Obstetricia',    'ESTAVEL',       'USG morfológica ok', '2026-07-20 09:00:00', '2026-07-20 09:00:00'),
    (10, 9,  '2026-08-01 15:40:00', 'TELEFONE', 'Enf. Marcos Lima',    'Enfermagem',     'ORIENTADO',     'Revisao de polifarmacia', '2026-08-01 15:40:00', '2026-08-01 15:40:00'),
    (11, 11, '2026-05-20 13:00:00', 'TELEFONE', 'Enf. Paula Reis',     'Enfermagem',     'AGENDADO',      'Retorno pos alta', '2026-05-20 13:00:00', '2026-05-20 13:00:00'),
    (12, 11, '2026-06-03 13:00:00', 'PRESENCIAL','Dr. Igor Santos',    'Clinica Medica', 'ESTAVEL',       'Alta do programa em avaliacao', '2026-06-03 13:00:00', '2026-06-03 13:00:00'),
    (13, 12, '2026-07-15 08:45:00', 'APP',      'Enf. Joana Pires',    'Enfermagem',     'ORIENTADO',     'Adesao ao losartana', '2026-07-15 08:45:00', '2026-07-15 08:45:00'),
    (14, 7,  '2026-09-08 11:10:00', 'DOMICILIAR','Fisio. Renata Dias', 'Fisioterapia',   'ALERTA',        'Risco de queda alto', '2026-09-08 11:10:00', '2026-09-08 11:10:00'),
    (15, 15, '2026-06-10 17:00:00', 'TELEFONE', 'Enf. Paula Reis',     'Enfermagem',     'ESTAVEL',       'Pos alta sem intercorrencia', '2026-06-10 17:00:00', '2026-06-10 17:00:00'),
    (16, 1,  '2026-09-01 10:00:00', 'TELEFONE', 'Enf. Paula Reis',     'Enfermagem',     'ALERTA',        'HbA1c fora da meta', '2026-09-01 10:00:00', '2026-09-01 10:00:00'),
    (17, 3,  '2026-09-10 09:20:00', 'PRESENCIAL','Dr. Carlos Mello',   'Endocrinologia', 'AGENDADO',      'Ajuste de insulina', '2026-09-10 09:20:00', '2026-09-10 09:20:00'),
    (18, 6,  '2026-05-02 12:00:00', 'TELEFONE', 'Enf. Joana Pires',    'Enfermagem',     'ORIENTADO',     'PA no limite', '2026-05-02 12:00:00', '2026-05-02 12:00:00');

INSERT INTO resultados_exames.tipos_exame
    (id, codigo_tuss, nome, especialidade, material, created_at, updated_at)
VALUES
    (1,  '40304361', 'Hemograma completo',          'Patologia Clinica', 'Sangue',     '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (2,  '40302040', 'Glicose',                     'Patologia Clinica', 'Sangue',     '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (3,  '40302741', 'Hemoglobina glicada',         'Patologia Clinica', 'Sangue',     '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (4,  '40301621', 'Colesterol total',            'Patologia Clinica', 'Sangue',     '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (5,  '40301648', 'HDL colesterol',              'Patologia Clinica', 'Sangue',     '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (6,  '40302547', 'Creatinina',                  'Patologia Clinica', 'Sangue',     '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (7,  '40101010', 'TSH',                         'Patologia Clinica', 'Sangue',     '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (8,  '40901032', 'USG obstetrica',              'Imagem',            NULL,         '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (9,  '40805018', 'ECG',                         'Cardiologia',       NULL,         '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (10, '40307018', 'Sumario de urina',            'Patologia Clinica', 'Urina',      '2024-01-01 08:00:00', '2026-01-01 08:00:00');

INSERT INTO resultados_exames.pedidos_exame
    (id, beneficiario_id, tipo_exame_id, dt_pedido, medico_solicitante, crm, unidade, status, created_at, updated_at)
VALUES
    (1,  1,  3, '2026-06-20', 'Dr. Carlos Mello',  'CRM-RJ 12345', 'Lab Central RJ',     'CONCLUIDO', '2026-06-20 08:00:00', '2026-06-22 08:00:00'),
    (2,  1,  2, '2026-06-20', 'Dr. Carlos Mello',  'CRM-RJ 12345', 'Lab Central RJ',     'CONCLUIDO', '2026-06-20 08:00:00', '2026-06-22 08:00:00'),
    (3,  1,  3, '2026-08-28', 'Dr. Carlos Mello',  'CRM-RJ 12345', 'Lab Central RJ',     'CONCLUIDO', '2026-08-28 08:00:00', '2026-08-30 08:00:00'),
    (4,  2,  4, '2026-05-10', 'Dra. Livia Prado',  'CRM-RJ 22331', 'Lab Niteroi',        'CONCLUIDO', '2026-05-10 08:00:00', '2026-05-12 08:00:00'),
    (5,  2,  5, '2026-05-10', 'Dra. Livia Prado',  'CRM-RJ 22331', 'Lab Niteroi',        'CONCLUIDO', '2026-05-10 08:00:00', '2026-05-12 08:00:00'),
    (6,  4,  3, '2026-08-01', 'Dr. Carlos Mello',  'CRM-MG 33445', 'Lab BH Centro',      'CONCLUIDO', '2026-08-01 08:00:00', '2026-08-03 08:00:00'),
    (7,  4,  6, '2026-08-01', 'Dr. Carlos Mello',  'CRM-MG 33445', 'Lab BH Centro',      'CONCLUIDO', '2026-08-01 08:00:00', '2026-08-03 08:00:00'),
    (8,  8,  1, '2026-07-15', 'Dra. Helena Costa', 'CRM-MG 99881', 'Lab JF',             'CONCLUIDO', '2026-07-15 08:00:00', '2026-07-16 08:00:00'),
    (9,  19, 8, '2026-07-18', 'Dra. Helena Costa', 'CRM-RJ 55667', 'Clinica Materna RJ', 'CONCLUIDO', '2026-07-18 08:00:00', '2026-07-18 18:00:00'),
    (10, 13, 2, '2026-06-02', 'Dra. Livia Prado',  'CRM-SP 11223', 'Lab Paulista',       'CONCLUIDO', '2026-06-02 08:00:00', '2026-06-03 08:00:00'),
    (11, 14, 6, '2026-09-01', 'Dr. Igor Santos',   'CRM-MG 44556', 'Lab Uberlandia',     'CONCLUIDO', '2026-09-01 08:00:00', '2026-09-02 08:00:00'),
    (12, 20, 7, '2026-08-10', 'Dra. Livia Prado',  'CRM-SP 11223', 'Lab Paulista',       'CONCLUIDO', '2026-08-10 08:00:00', '2026-08-12 08:00:00'),
    (13, 5,  1, '2026-04-04', 'Dr. Igor Santos',   'CRM-SP 77889', 'Lab Campinas',       'CONCLUIDO', '2026-04-04 08:00:00', '2026-04-05 08:00:00'),
    (14, 11, 9, '2026-05-14', 'Dr. Carlos Mello',  'CRM-GO 33440', 'Hospital Goiania',   'CONCLUIDO', '2026-05-14 08:00:00', '2026-05-14 12:00:00'),
    (15, 16, 4, '2026-07-01', 'Dra. Livia Prado',  'CRM-SP 11223', 'Lab Campinas',       'CONCLUIDO', '2026-07-01 08:00:00', '2026-07-02 08:00:00'),
    (16, 3,  10,'2026-03-03', 'Dr. Igor Santos',   'CRM-SP 77889', 'Lab Paulista',       'CANCELADO', '2026-03-03 08:00:00', '2026-03-04 08:00:00'),
    (17, 7,  2, '2026-08-20', 'Dra. Helena Costa', 'CRM-SP 22110', 'Lab Santos',         'COLETADO',  '2026-08-20 08:00:00', '2026-08-20 08:00:00'),
    (18, 12, 1, '2026-09-08', 'Dr. Carlos Mello',  'CRM-RJ 12345', 'Lab Central RJ',     'SOLICITADO','2026-09-08 08:00:00', '2026-09-08 08:00:00');

INSERT INTO resultados_exames.resultados_exame
    (id, pedido_id, dt_liberacao, valor_numerico, unidade_medida, valor_referencia_min, valor_referencia_max, valor_texto, flag_alterado, laboratorio, created_at, updated_at)
VALUES
    (1,  1,  '2026-06-22 16:00:00', 8.400, '%',    4.000,  5.600,  NULL, TRUE,  'Lab Central RJ', '2026-06-22 16:00:00', '2026-06-22 16:00:00'),
    (2,  2,  '2026-06-22 16:05:00', 186.000,'mg/dL',70.000, 99.000, NULL, TRUE,  'Lab Central RJ', '2026-06-22 16:05:00', '2026-06-22 16:05:00'),
    (3,  3,  '2026-08-30 11:00:00', 8.900, '%',    4.000,  5.600,  NULL, TRUE,  'Lab Central RJ', '2026-08-30 11:00:00', '2026-08-30 11:00:00'),
    (4,  4,  '2026-05-12 09:40:00', 242.000,'mg/dL',0.000,  190.000,NULL, TRUE,  'Lab Niteroi',    '2026-05-12 09:40:00', '2026-05-12 09:40:00'),
    (5,  5,  '2026-05-12 09:42:00', 38.000, 'mg/dL',40.000, 60.000, NULL, TRUE,  'Lab Niteroi',    '2026-05-12 09:42:00', '2026-05-12 09:42:00'),
    (6,  6,  '2026-08-03 14:10:00', 9.100, '%',    4.000,  5.600,  NULL, TRUE,  'Lab BH Centro',  '2026-08-03 14:10:00', '2026-08-03 14:10:00'),
    (7,  7,  '2026-08-03 14:12:00', 1.800, 'mg/dL',0.600,  1.300,  NULL, TRUE,  'Lab BH Centro',  '2026-08-03 14:12:00', '2026-08-03 14:12:00'),
    (8,  8,  '2026-07-16 10:00:00', NULL,  NULL,   NULL,   NULL,   'Hemograma sem alteracoes', FALSE, 'Lab JF', '2026-07-16 10:00:00', '2026-07-16 10:00:00'),
    (9,  9,  '2026-07-18 18:20:00', NULL,  NULL,   NULL,   NULL,   'Feto unico, vitalidade preservada', FALSE, 'Clinica Materna RJ', '2026-07-18 18:20:00', '2026-07-18 18:20:00'),
    (10, 10, '2026-06-03 11:30:00', 102.000,'mg/dL',70.000, 99.000, NULL, TRUE,  'Lab Paulista',   '2026-06-03 11:30:00', '2026-06-03 11:30:00'),
    (11, 11, '2026-09-02 15:00:00', 1.100, 'mg/dL',0.600,  1.300,  NULL, FALSE, 'Lab Uberlandia', '2026-09-02 15:00:00', '2026-09-02 15:00:00'),
    (12, 12, '2026-08-12 08:50:00', 4.200, 'uUI/mL',0.400, 4.000,  NULL, TRUE,  'Lab Paulista',   '2026-08-12 08:50:00', '2026-08-12 08:50:00'),
    (13, 13, '2026-04-05 09:10:00', NULL,  NULL,   NULL,   NULL,   'Leucocitos no limite', FALSE, 'Lab Campinas', '2026-04-05 09:10:00', '2026-04-05 09:10:00'),
    (14, 14, '2026-05-14 12:30:00', NULL,  NULL,   NULL,   NULL,   'Ritmo sinusal', FALSE, 'Hospital Goiania', '2026-05-14 12:30:00', '2026-05-14 12:30:00'),
    (15, 15, '2026-07-02 16:45:00', 178.000,'mg/dL',0.000,  190.000,NULL, FALSE, 'Lab Campinas',   '2026-07-02 16:45:00', '2026-07-02 16:45:00');

INSERT INTO autorizacoes.procedimentos
    (id, codigo_tuss, nome, grupo, porte, exige_autorizacao, created_at, updated_at)
VALUES
    (1,  '10101012', 'Consulta em consultorio',            'Consultas',        '0',  FALSE, '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (2,  '30715015', 'RM de joelho',                       'Diagnostico',      '3',  TRUE,  '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (3,  '31001010', 'Internacao clinica',                 'Internacao',       '5',  TRUE,  '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (4,  '31309039', 'Facectomia com LIO',                 'Cirurgia',         '4',  TRUE,  '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (5,  '40805018', 'Eletrocardiograma',                  'Diagnostico',      '1',  FALSE, '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (6,  '31601014', 'Quimioterapia (sessao)',             'Oncologia',        '4',  TRUE,  '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (7,  '40304361', 'Hemograma completo',                 'SADT',             '1',  FALSE, '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (8,  '30714019', 'TC de torax',                        'Diagnostico',      '3',  TRUE,  '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (9,  '30905012', 'Fisioterapia motora (sessao)',       'Terapias',         '2',  TRUE,  '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (10, '31401012', 'Endoscopia digestiva alta',          'Diagnostico',      '3',  TRUE,  '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (11, '10102019', 'Consulta domiciliar',                'Consultas',        '1',  TRUE,  '2024-01-01 08:00:00', '2026-01-01 08:00:00'),
    (12, '31304010', 'Artroscopia de joelho',              'Cirurgia',         '5',  TRUE,  '2024-01-01 08:00:00', '2026-01-01 08:00:00');

INSERT INTO autorizacoes.guias_autorizacao
    (id, numero_guia, beneficiario_id, procedimento_id, dt_solicitacao, dt_autorizacao, dt_validade, status, senha, qtd_solicitada, qtd_autorizada, cid, created_at, updated_at)
VALUES
    (1,  'G202600001', 12, 2,  '2026-08-01', '2026-08-02', '2026-10-01', 'AUTORIZADA',    'SN88021', 1,  1,  'M17', '2026-08-01 09:00:00', '2026-08-02 09:00:00'),
    (2,  'G202600002', 4,  3,  '2026-07-10', '2026-07-10', '2026-07-20', 'AUTORIZADA',    'SN88022', 1,  1,  'E11', '2026-07-10 09:00:00', '2026-07-10 18:00:00'),
    (3,  'G202600003', 8,  4,  '2026-06-12', '2026-06-14', '2026-09-14', 'AUTORIZADA',    'SN88023', 1,  1,  'H25', '2026-06-12 09:00:00', '2026-06-14 09:00:00'),
    (4,  'G202600004', 1,  8,  '2026-09-02', NULL,         NULL,         'EM_ANALISE',    NULL,      1,  NULL,'J18', '2026-09-02 09:00:00', '2026-09-02 09:00:00'),
    (5,  'G202600005', 20, 6,  '2026-05-05', '2026-05-06', '2026-08-06', 'AUTORIZADA',    'SN88025', 6,  4,  'C50', '2026-05-05 09:00:00', '2026-05-06 09:00:00'),
    (6,  'G202600006', 14, 9,  '2026-08-20', '2026-08-21', '2026-11-21', 'AUTORIZADA',    'SN88026', 10, 10, 'M54', '2026-08-20 09:00:00', '2026-08-21 09:00:00'),
    (7,  'G202600007', 2,  12, '2026-04-03', '2026-04-08', NULL,         'NEGADA',        NULL,      1,  0,  'M23', '2026-04-03 09:00:00', '2026-04-08 09:00:00'),
    (8,  'G202600008', 19, 11, '2026-07-01', '2026-07-01', '2026-10-01', 'AUTORIZADA',    'SN88028', 4,  4,  'O24', '2026-07-01 09:00:00', '2026-07-01 09:00:00'),
    (9,  'G202600009', 13, 10, '2026-09-10', NULL,         NULL,         'EM_ANALISE',    NULL,      1,  NULL,'K21', '2026-09-10 09:00:00', '2026-09-10 09:00:00'),
    (10, 'G202600010', 5,  2,  '2026-03-15', '2026-03-16', '2026-05-16', 'VENCIDA',       'SN88030', 1,  1,  'M17', '2026-03-15 09:00:00', '2026-05-17 09:00:00'),
    (11, 'G202600011', 16, 8,  '2026-08-28', '2026-08-29', '2026-11-29', 'AUTORIZADA',    'SN88031', 1,  1,  'J44', '2026-08-28 09:00:00', '2026-08-29 09:00:00'),
    (12, 'G202600012', 11, 3,  '2026-05-11', '2026-05-11', '2026-05-18', 'UTILIZADA',     'SN88032', 1,  1,  'I10', '2026-05-11 09:00:00', '2026-05-16 09:00:00'),
    (13, 'G202600013', 18, 6,  '2026-02-02', NULL,         NULL,         'CANCELADA',     NULL,      8,  NULL,'C18', '2026-02-02 09:00:00', '2026-03-20 09:00:00'),
    (14, 'G202600014', 7,  9,  '2026-08-05', '2026-08-06', '2026-11-06', 'AUTORIZADA',    'SN88034', 8,  8,  'O26', '2026-08-05 09:00:00', '2026-08-06 09:00:00'),
    (15, 'G202600015', 3,  2,  '2026-09-12', NULL,         NULL,         'EM_ANALISE',    NULL,      1,  NULL,'M25', '2026-09-12 09:00:00', '2026-09-12 09:00:00');

INSERT INTO autorizacoes.eventos_guia
    (id, guia_id, dt_evento, status_anterior, status_novo, usuario, created_at, updated_at)
VALUES
    (1,  1,  '2026-08-01 09:01:00', NULL,          'SOLICITADA',   'sistema',          '2026-08-01 09:01:00', '2026-08-01 09:01:00'),
    (2,  1,  '2026-08-02 09:00:00', 'SOLICITADA',  'AUTORIZADA',   'aud. marina',      '2026-08-02 09:00:00', '2026-08-02 09:00:00'),
    (3,  2,  '2026-07-10 09:00:00', NULL,          'SOLICITADA',   'sistema',          '2026-07-10 09:00:00', '2026-07-10 09:00:00'),
    (4,  2,  '2026-07-10 18:00:00', 'SOLICITADA',  'AUTORIZADA',   'aud. paulo',       '2026-07-10 18:00:00', '2026-07-10 18:00:00'),
    (5,  4,  '2026-09-02 09:00:00', NULL,          'SOLICITADA',   'sistema',          '2026-09-02 09:00:00', '2026-09-02 09:00:00'),
    (6,  4,  '2026-09-02 11:00:00', 'SOLICITADA',  'EM_ANALISE',   'aud. marina',      '2026-09-02 11:00:00', '2026-09-02 11:00:00'),
    (7,  7,  '2026-04-03 09:00:00', NULL,          'SOLICITADA',   'sistema',          '2026-04-03 09:00:00', '2026-04-03 09:00:00'),
    (8,  7,  '2026-04-08 09:00:00', 'SOLICITADA',  'NEGADA',       'aud. paulo',       '2026-04-08 09:00:00', '2026-04-08 09:00:00'),
    (9,  5,  '2026-05-05 09:00:00', NULL,          'SOLICITADA',   'sistema',          '2026-05-05 09:00:00', '2026-05-05 09:00:00'),
    (10, 5,  '2026-05-06 09:00:00', 'SOLICITADA',  'AUTORIZADA',   'aud. marina',      '2026-05-06 09:00:00', '2026-05-06 09:00:00'),
    (11, 12, '2026-05-11 09:00:00', NULL,          'SOLICITADA',   'sistema',          '2026-05-11 09:00:00', '2026-05-11 09:00:00'),
    (12, 12, '2026-05-11 12:00:00', 'SOLICITADA',  'AUTORIZADA',   'aud. paulo',       '2026-05-11 12:00:00', '2026-05-11 12:00:00'),
    (13, 12, '2026-05-16 09:00:00', 'AUTORIZADA',  'UTILIZADA',    'sistema',          '2026-05-16 09:00:00', '2026-05-16 09:00:00'),
    (14, 13, '2026-02-02 09:00:00', NULL,          'SOLICITADA',   'sistema',          '2026-02-02 09:00:00', '2026-02-02 09:00:00'),
    (15, 13, '2026-03-20 09:00:00', 'SOLICITADA',  'CANCELADA',    'sistema',          '2026-03-20 09:00:00', '2026-03-20 09:00:00'),
    (16, 9,  '2026-09-10 09:00:00', NULL,          'SOLICITADA',   'sistema',          '2026-09-10 09:00:00', '2026-09-10 09:00:00'),
    (17, 9,  '2026-09-10 15:00:00', 'SOLICITADA',  'EM_ANALISE',   'aud. marina',      '2026-09-10 15:00:00', '2026-09-10 15:00:00'),
    (18, 15, '2026-09-12 09:00:00', NULL,          'SOLICITADA',   'sistema',          '2026-09-12 09:00:00', '2026-09-12 09:00:00'),
    (19, 15, '2026-09-12 10:30:00', 'SOLICITADA',  'EM_ANALISE',   'aud. paulo',       '2026-09-12 10:30:00', '2026-09-12 10:30:00');

INSERT INTO faturamento.prestadores
    (id, cnpj, razao_social, tipo, municipio, uf, ativo, created_at, updated_at)
VALUES
    (1, '12.345.678/0001-90', 'Hospital Unimed Rio',           'Hospital',     'Rio de Janeiro', 'RJ', TRUE,  '2020-01-01 08:00:00', '2026-01-01 08:00:00'),
    (2, '23.456.789/0001-01', 'Clinica Orto Vida',             'Clinica',      'Niteroi',        'RJ', TRUE,  '2021-03-01 08:00:00', '2026-01-01 08:00:00'),
    (3, '34.567.890/0001-12', 'Lab Central Diagnosticos',      'Laboratorio',  'Rio de Janeiro', 'RJ', TRUE,  '2019-06-01 08:00:00', '2026-01-01 08:00:00'),
    (4, '45.678.901/0001-23', 'Hospital BH Saude',             'Hospital',     'Belo Horizonte', 'MG', TRUE,  '2018-02-01 08:00:00', '2026-01-01 08:00:00'),
    (5, '56.789.012/0001-34', 'Onco Vida SP',                  'Clinica',      'Sao Paulo',      'SP', TRUE,  '2020-09-01 08:00:00', '2026-01-01 08:00:00'),
    (6, '67.890.123/0001-45', 'FisioMais',                     'Clinica',      'Uberlandia',     'MG', TRUE,  '2022-01-01 08:00:00', '2026-01-01 08:00:00'),
    (7, '78.901.234/0001-56', 'Materna Care',                  'Clinica',      'Rio de Janeiro', 'RJ', TRUE,  '2021-11-01 08:00:00', '2026-01-01 08:00:00'),
    (8, '89.012.345/0001-67', 'Hospital Campinas Norte',       'Hospital',     'Campinas',       'SP', FALSE, '2017-04-01 08:00:00', '2025-12-01 08:00:00');

INSERT INTO faturamento.contas_medicas
    (id, numero_conta, guia_id, prestador_id, competencia, dt_emissao, valor_apresentado, valor_glosado, valor_pago, status, created_at, updated_at)
VALUES
    (1,  'C202608001', 1,  2, '2026-08', '2026-08-20',  950.00,    0.00,    950.00,  'PAGA',        '2026-08-20 08:00:00', '2026-09-05 08:00:00'),
    (2,  'C202607001', 2,  4, '2026-07', '2026-07-22',  8420.50,  320.50,  8100.00,  'PAGA',        '2026-07-22 08:00:00', '2026-08-10 08:00:00'),
    (3,  'C202606001', 3,  4, '2026-06', '2026-06-28',  4100.00,    0.00,  4100.00,  'PAGA',        '2026-06-28 08:00:00', '2026-07-15 08:00:00'),
    (4,  'C202605001', 5,  5, '2026-05', '2026-05-30', 12600.00, 2100.00, 10500.00,  'PAGA',        '2026-05-30 08:00:00', '2026-06-20 08:00:00'),
    (5,  'C202608002', 6,  6, '2026-08', '2026-08-31',  1800.00,    0.00,     0.00,  'EM_ANALISE',  '2026-08-31 08:00:00', '2026-09-10 08:00:00'),
    (6,  'C202607002', 8,  7, '2026-07', '2026-07-25',   640.00,    0.00,   640.00,  'PAGA',        '2026-07-25 08:00:00', '2026-08-08 08:00:00'),
    (7,  'C202605002', 12, 4, '2026-05', '2026-05-20',  5230.00,  230.00,  5000.00,  'PAGA',        '2026-05-20 08:00:00', '2026-06-05 08:00:00'),
    (8,  'C202608003', 11, 1, '2026-08', '2026-09-02',  1500.00,    0.00,     0.00,  'APRESENTADA', '2026-09-02 08:00:00', '2026-09-02 08:00:00'),
    (9,  'C202603001', 10, 2, '2026-03', '2026-03-28',   980.00,  980.00,     0.00,  'GLOSADA',     '2026-03-28 08:00:00', '2026-05-20 08:00:00'),
    (10, 'C202608004', 14, 6, '2026-08', '2026-08-30',  1440.00,    0.00,     0.00,  'EM_ANALISE',  '2026-08-30 08:00:00', '2026-09-12 08:00:00'),
    (11, 'C202609001', NULL,3,'2026-09', '2026-09-15',   220.00,    0.00,     0.00,  'APRESENTADA', '2026-09-15 08:00:00', '2026-09-15 08:00:00'),
    (12, 'C202607003', NULL,3,'2026-07', '2026-07-18',   310.00,   40.00,   270.00,  'PAGA',        '2026-07-18 08:00:00', '2026-08-01 08:00:00');

INSERT INTO faturamento.itens_conta
    (id, conta_id, procedimento_id, descricao, qtd, valor_unitario, valor_total, glosa_flag, motivo_glosa, created_at, updated_at)
VALUES
    (1,  1,  2,  'RM de joelho',                    1,  950.00,   950.00, FALSE, NULL,                        '2026-08-20 08:00:00', '2026-08-20 08:00:00'),
    (2,  2,  3,  'Diaria internacao clinica',        3, 2600.00,  7800.00, FALSE, NULL,                        '2026-07-22 08:00:00', '2026-07-22 08:00:00'),
    (3,  2,  1,  'Consulta internacao',              2,  210.25,   420.50, TRUE,  'Pacote ja contempla visita','2026-07-22 08:00:00', '2026-08-10 08:00:00'),
    (4,  3,  4,  'Facectomia com LIO',               1, 4100.00,  4100.00, FALSE, NULL,                        '2026-06-28 08:00:00', '2026-06-28 08:00:00'),
    (5,  4,  6,  'Sessao de quimioterapia',          4, 3150.00, 12600.00, TRUE,  'Qtd autorizada = 4 de 6',   '2026-05-30 08:00:00', '2026-06-20 08:00:00'),
    (6,  5,  9,  'Fisioterapia motora',             10,  180.00,  1800.00, FALSE, NULL,                        '2026-08-31 08:00:00', '2026-08-31 08:00:00'),
    (7,  6,  11, 'Consulta domiciliar obstetrica',   4,  160.00,   640.00, FALSE, NULL,                        '2026-07-25 08:00:00', '2026-07-25 08:00:00'),
    (8,  7,  3,  'Diaria internacao clinica',        2, 2500.00,  5000.00, FALSE, NULL,                        '2026-05-20 08:00:00', '2026-05-20 08:00:00'),
    (9,  7,  5,  'ECG internacao',                   1,  230.00,   230.00, TRUE,  'Exame sem pedido anexo',    '2026-05-20 08:00:00', '2026-06-05 08:00:00'),
    (10, 8,  8,  'TC de torax',                      1, 1500.00,  1500.00, FALSE, NULL,                        '2026-09-02 08:00:00', '2026-09-02 08:00:00'),
    (11, 9,  2,  'RM de joelho',                     1,  980.00,   980.00, TRUE,  'Guia vencida',              '2026-03-28 08:00:00', '2026-05-20 08:00:00'),
    (12, 10, 9,  'Fisioterapia motora',              8,  180.00,  1440.00, FALSE, NULL,                        '2026-08-30 08:00:00', '2026-08-30 08:00:00'),
    (13, 11, 7,  'Hemograma completo',               1,  220.00,   220.00, FALSE, NULL,                        '2026-09-15 08:00:00', '2026-09-15 08:00:00'),
    (14, 12, 7,  'Hemograma completo',               1,  220.00,   220.00, FALSE, NULL,                        '2026-07-18 08:00:00', '2026-07-18 08:00:00'),
    (15, 12, 1,  'Taxa de coleta',                   1,   90.00,    90.00, TRUE,  'Taxa nao prevista',         '2026-07-18 08:00:00', '2026-08-01 08:00:00');
