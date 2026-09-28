"""Consultas de demonstracao no warehouse (Trino + MinIO)."""

from __future__ import annotations

import sys

from trino.dbapi import connect

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

QUERIES = [
    (
        "Datamart de cuidado integrado",
        """
        select nome_beneficiario, idade, uf, nome_plano, qtd_programas_ativos,
               maior_risco, qtd_alertas, dias_sem_contato
        from iceberg.cuidado_integrado_ouro.mart_cuidado_integrado
        order by qtd_alertas desc, dias_sem_contato
        """,
    ),
    (
        "Exames fora da referencia",
        """
        select nome_beneficiario, nome_exame, valor_numerico, unidade_medida,
               valor_referencia_min, valor_referencia_max, laboratorio
        from iceberg.resultados_exames_ouro.mart_exames_criticos
        order by dt_liberacao desc
        """,
    ),
    (
        "SLA de autorizacoes",
        """
        select status_guia, grupo_procedimento, qtd_guias, sla_medio_dias, qtd_fora_sla
        from iceberg.autorizacoes_ouro.mart_autorizacoes_sla
        order by qtd_guias desc
        """,
    ),
    (
        "Faturamento por competencia",
        """
        select competencia, razao_social, qtd_contas, valor_apresentado,
               valor_glosado, valor_pago, tx_glosa
        from iceberg.faturamento_ouro.mart_faturamento_competencia
        order by competencia, valor_apresentado desc
        """,
    ),
]


def print_table(rows, columns) -> None:
    if not rows:
        print("  (sem linhas)")
        return
    widths = [len(str(col)) for col in columns]
    text_rows = []
    for row in rows:
        values = ["" if value is None else str(value) for value in row]
        text_rows.append(values)
        for idx, value in enumerate(values):
            widths[idx] = max(widths[idx], len(value))
    header = " | ".join(str(col).ljust(widths[idx]) for idx, col in enumerate(columns))
    print("  " + header)
    print("  " + "-+-".join("-" * width for width in widths))
    for values in text_rows:
        print("  " + " | ".join(values[idx].ljust(widths[idx]) for idx in range(len(columns))))


def main() -> int:
    conn = connect(host="localhost", port=8080, user="dbt", catalog="iceberg", http_scheme="http")
    cursor = conn.cursor()
    try:
        for title, sql in QUERIES:
            print(f"\n== {title} ==")
            cursor.execute(sql)
            rows = cursor.fetchall()
            columns = [item[0] for item in cursor.description]
            print_table(rows, columns)
    finally:
        conn.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
