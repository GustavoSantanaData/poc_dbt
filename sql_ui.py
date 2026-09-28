"""Console SQL no navegador, ja conectado no Trino."""

from __future__ import annotations

import html
import sys
import traceback
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs

from trino.dbapi import connect

HOST = "127.0.0.1"
PORT = 8501
TRINO_HOST = "localhost"
TRINO_PORT = 8080

EXAMPLES = [
    ("Origem Postgres", "select * from postgres.cuidado_integrado.beneficiarios limit 20"),
    ("Schemas Iceberg", "show schemas from iceberg"),
    ("Tabelas bronze", "show tables from iceberg.cuidado_integrado_bronze"),
    ("Bronze beneficiarios", "select * from iceberg.cuidado_integrado_bronze.bronze_beneficiarios limit 20"),
    ("Prata beneficiarios", "select * from iceberg.cuidado_integrado_prata.prata_beneficiarios limit 20"),
    ("Datamart cuidado", "select * from iceberg.cuidado_integrado_ouro.mart_cuidado_integrado"),
]


def run_sql(sql: str):
    conn = connect(
        host=TRINO_HOST,
        port=TRINO_PORT,
        user="dbt",
        catalog="iceberg",
        schema="default",
        http_scheme="http",
    )
    try:
        cursor = conn.cursor()
        cursor.execute(sql)
        columns = [item[0] for item in (cursor.description or [])]
        rows = cursor.fetchall() if cursor.description is not None else []
        return columns, rows, None
    finally:
        conn.close()


def page(sql: str = "", columns=None, rows=None, error: str | None = None) -> bytes:
    sql = sql.strip() or EXAMPLES[0][1]
    example_links = "".join(
        f'<button type="button" class="chip" data-sql="{html.escape(query, quote=True)}">{html.escape(label)}</button>'
        for label, query in EXAMPLES
    )
    result_html = ""
    if error:
        result_html = f'<pre class="error">{html.escape(error)}</pre>'
    elif columns is not None:
        header = "".join(f"<th>{html.escape(str(col))}</th>" for col in columns)
        body = []
        for row in rows or []:
            cells = "".join(
                f"<td>{html.escape('' if value is None else str(value))}</td>" for value in row
            )
            body.append(f"<tr>{cells}</tr>")
        count = 0 if rows is None else len(rows)
        result_html = (
            f'<p class="meta">{count} linha(s)</p>'
            f'<div class="table-wrap"><table><thead><tr>{header}</tr></thead>'
            f"<tbody>{''.join(body)}</tbody></table></div>"
        )

    content = f"""<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <title>PoC Unimed — SQL</title>
  <style>
    :root {{ font-family: Segoe UI, sans-serif; background: #0f172a; color: #e2e8f0; }}
    body {{ margin: 0 auto; max-width: 1100px; padding: 24px; }}
    h1 {{ margin: 0 0 8px; font-size: 22px; }}
    .sub {{ color: #94a3b8; margin-bottom: 16px; }}
    textarea {{ width: 100%; min-height: 140px; background: #1e293b; color: #f8fafc;
      border: 1px solid #334155; border-radius: 8px; padding: 12px; font: 14px/1.4 Consolas, monospace; }}
    button.run {{ margin-top: 10px; background: #2563eb; color: white; border: 0; padding: 10px 16px;
      border-radius: 8px; cursor: pointer; font-weight: 600; }}
    .chips {{ display: flex; flex-wrap: wrap; gap: 8px; margin: 12px 0; }}
    .chip {{ background: #1e293b; color: #cbd5e1; border: 1px solid #334155; border-radius: 999px;
      padding: 6px 10px; cursor: pointer; }}
    table {{ border-collapse: collapse; width: 100%; font-size: 13px; }}
    th, td {{ border-bottom: 1px solid #334155; padding: 8px 10px; text-align: left; white-space: nowrap; }}
    th {{ color: #93c5fd; }}
    .table-wrap {{ overflow: auto; background: #1e293b; border-radius: 8px; }}
    .error {{ background: #450a0a; color: #fecaca; padding: 12px; border-radius: 8px; white-space: pre-wrap; }}
    .meta {{ color: #94a3b8; }}
  </style>
</head>
<body>
  <h1>Console SQL (Trino)</h1>
  <p class="sub">A porta 8080 e so o painel do cluster. Escreva SQL aqui. Catalogos: iceberg (lakehouse/MinIO) e postgres (origem).</p>
  <div class="chips">{example_links}</div>
  <form method="post">
    <textarea name="sql" id="sql">{html.escape(sql)}</textarea>
    <button class="run" type="submit">Rodar SQL</button>
  </form>
  {result_html}
  <script>
    document.querySelectorAll('.chip').forEach((btn) => {{
      btn.addEventListener('click', () => {{
        document.getElementById('sql').value = btn.dataset.sql;
      }});
    }});
  </script>
</body>
</html>"""
    return content.encode("utf-8")


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        return

    def do_GET(self):
        self._respond(page())

    def do_POST(self):
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length).decode("utf-8")
        sql = parse_qs(raw).get("sql", [""])[0]
        try:
            columns, rows, _ = run_sql(sql)
            self._respond(page(sql=sql, columns=columns, rows=rows))
        except Exception:
            self._respond(page(sql=sql, error=traceback.format_exc()), status=400)

    def _respond(self, body: bytes, status: int = 200):
        self.send_response(status)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def main() -> int:
    if sys.platform == "win32":
        try:
            sys.stdout.reconfigure(encoding="utf-8")
        except Exception:
            pass
    print(f"Console SQL: http://{HOST}:{PORT}")
    print("Ctrl+C para sair.")
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
