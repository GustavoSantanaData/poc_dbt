"""Simulacao visual do Snowsight (Snowflake). Executa SQL no Trino."""

from __future__ import annotations

import json
import os
import sys
import time
import traceback
from datetime import date, datetime
from decimal import Decimal
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

from trino.dbapi import connect

HOST = os.environ.get("BIND_HOST", "0.0.0.0")
PORT = int(os.environ.get("PORT", "8501"))
TRINO_HOST = os.environ.get("TRINO_HOST", "localhost")
TRINO_PORT = int(os.environ.get("TRINO_PORT", "8080"))
TRINO_USER = os.environ.get("TRINO_USER", "dbt")
ROW_LIMIT = 500
HIDDEN_SCHEMAS = {"information_schema", "sys", "system"}


def json_default(value):
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    if isinstance(value, Decimal):
        return float(value)
    return str(value)


def trino_conn(catalog="iceberg", schema="default"):
    return connect(
        host=TRINO_HOST,
        port=TRINO_PORT,
        user=TRINO_USER,
        catalog=catalog,
        schema=schema,
        http_scheme="http",
    )


def wait_for_trino(timeout: int = 180) -> None:
    deadline = time.time() + timeout
    last = ""
    while time.time() < deadline:
        try:
            conn = trino_conn()
            cur = conn.cursor()
            cur.execute("select 1")
            cur.fetchall()
            conn.close()
            return
        except Exception as exc:
            last = str(exc)
            time.sleep(2)
    raise RuntimeError(f"Trino nao ficou pronto: {last}")


def fetch(sql: str, catalog="iceberg", schema="default"):
    conn = trino_conn(catalog, schema)
    try:
        cur = conn.cursor()
        started = time.time()
        cur.execute(sql)
        columns = [item[0] for item in (cur.description or [])]
        rows = cur.fetchmany(ROW_LIMIT) if cur.description is not None else []
        elapsed_ms = int((time.time() - started) * 1000)
        return {"columns": columns, "rows": rows, "elapsed_ms": elapsed_ms, "truncated": len(rows) >= ROW_LIMIT}
    finally:
        conn.close()


def catalogs():
    result = fetch("show catalogs")
    names = [row[0] for row in result["rows"] if row and row[0] not in {"system"}]
    return names


def schemas(catalog: str):
    result = fetch(f"show schemas from {catalog}")
    return [row[0] for row in result["rows"] if row and row[0] not in HIDDEN_SCHEMAS]


def tables(catalog: str, schema: str):
    result = fetch(f"show tables from {catalog}.{schema}")
    return [row[0] for row in result["rows"]]


def columns(catalog: str, schema: str, table: str):
    sql = (
        "select column_name, data_type from "
        f"{catalog}.information_schema.columns "
        f"where table_schema = '{schema}' and table_name = '{table}' "
        "order by ordinal_position"
    )
    try:
        result = fetch(sql, catalog=catalog, schema="information_schema")
        return [{"name": row[0], "type": row[1]} for row in result["rows"]]
    except Exception:
        return []


INDEX_HTML = r"""<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <title>Snowsight — UNIMED_POC</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/ace/1.32.6/ace.min.css">
  <style>
    :root {
      --sf-blue: #29B5E8;
      --sf-blue-dark: #1B90C4;
      --sf-navy: #0B3A5B;
      --sf-run: #0066DD;
      --bg: #F4F6F8;
      --panel: #FFFFFF;
      --line: #E4E8EC;
      --text: #1B2330;
      --muted: #6B7785;
      --hover: #F0F7FC;
      --active: #E6F5FC;
      --sidebar: 220px;
    }
    * { box-sizing: border-box; }
    html, body { height: 100%; margin: 0; }
    body {
      font-family: "Segoe UI", "Helvetica Neue", Arial, sans-serif;
      background: var(--bg);
      color: var(--text);
      display: grid;
      grid-template-columns: var(--sidebar) 1fr;
      grid-template-rows: 48px 1fr;
      grid-template-areas: "top top" "nav main";
    }
    .top {
      grid-area: top;
      background: var(--panel);
      border-bottom: 1px solid var(--line);
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 16px;
    }
    .brand { display: flex; align-items: center; gap: 10px; font-weight: 700; color: var(--sf-navy); }
    .brand svg { width: 26px; height: 26px; }
    .search {
      flex: 1; max-width: 420px; margin: 0 24px;
      background: var(--bg); border: 1px solid var(--line); border-radius: 6px;
      padding: 7px 12px; color: var(--muted); font-size: 13px;
    }
    .user { display: flex; align-items: center; gap: 10px; font-size: 13px; }
    .avatar {
      width: 28px; height: 28px; border-radius: 50%; background: var(--sf-navy); color: white;
      display: grid; place-items: center; font-size: 12px; font-weight: 700;
    }
    .nav {
      grid-area: nav;
      background: var(--panel);
      border-right: 1px solid var(--line);
      padding: 12px 8px;
      display: flex; flex-direction: column; gap: 2px;
    }
    .nav button {
      display: flex; align-items: center; gap: 10px;
      border: 0; background: transparent; text-align: left;
      padding: 8px 10px; border-radius: 6px; cursor: pointer; color: var(--text); font-size: 13px;
    }
    .nav button:hover { background: var(--hover); }
    .nav button.active { background: var(--active); color: var(--sf-navy); font-weight: 600; }
    .nav .section { margin: 14px 10px 6px; font-size: 11px; color: var(--muted); letter-spacing: .04em; }
    .main { grid-area: main; display: grid; grid-template-rows: auto auto 1fr auto; min-width: 0; min-height: 0; }
    .context {
      background: var(--panel); border-bottom: 1px solid var(--line);
      display: flex; gap: 8px; align-items: center; padding: 8px 14px; flex-wrap: wrap;
    }
    .pill {
      border: 1px solid var(--line); background: var(--panel); border-radius: 6px;
      padding: 6px 10px; font-size: 12px; color: var(--text);
    }
    .pill b { color: var(--muted); font-weight: 600; margin-right: 6px; }
    .tabs { display: flex; gap: 0; background: var(--panel); border-bottom: 1px solid var(--line); padding: 0 8px; }
    .tab {
      border: 0; background: transparent; padding: 10px 14px; cursor: pointer; font-size: 13px;
      border-bottom: 2px solid transparent; color: var(--muted);
    }
    .tab.active { color: var(--sf-navy); border-bottom-color: var(--sf-blue); font-weight: 600; }
    .toolbar { display: flex; align-items: center; gap: 8px; padding: 8px 14px; background: var(--panel); }
    .run {
      background: var(--sf-run); color: white; border: 0; border-radius: 6px;
      padding: 7px 14px; font-weight: 600; cursor: pointer; display: flex; gap: 6px; align-items: center;
    }
    .run:disabled { opacity: .6; cursor: wait; }
    .ghost { border: 1px solid var(--line); background: white; border-radius: 6px; padding: 7px 10px; cursor: pointer; font-size: 12px; }
    #editor { height: 280px; border-bottom: 1px solid var(--line); }
    .results {
      background: var(--panel); min-height: 0; display: grid; grid-template-rows: auto 1fr;
    }
    .result-tabs { display: flex; gap: 12px; padding: 8px 14px; border-bottom: 1px solid var(--line); font-size: 13px; }
    .result-tabs span { cursor: pointer; color: var(--muted); padding-bottom: 6px; }
    .result-tabs span.active { color: var(--sf-navy); border-bottom: 2px solid var(--sf-blue); font-weight: 600; }
    .meta { color: var(--muted); font-size: 12px; margin-left: auto; }
    .table-wrap { overflow: auto; }
    table { border-collapse: collapse; width: max-content; min-width: 100%; font-size: 12px; }
    th { position: sticky; top: 0; background: #F7FAFC; text-align: left; padding: 8px 10px; border-bottom: 1px solid var(--line); color: var(--muted); font-weight: 600; }
    td { padding: 7px 10px; border-bottom: 1px solid #EEF1F4; white-space: nowrap; }
    tr:hover td { background: var(--hover); }
    .error { color: #B42318; padding: 12px 14px; white-space: pre-wrap; font-family: Consolas, monospace; font-size: 12px; }
    .empty { color: var(--muted); padding: 24px 14px; }
    .drawer {
      position: fixed; top: 48px; left: var(--sidebar); bottom: 0; width: 280px;
      background: var(--panel); border-right: 1px solid var(--line); overflow: auto; display: none; z-index: 3;
    }
    .drawer.open { display: block; }
    .drawer h3 { margin: 12px 12px 8px; font-size: 13px; }
    .tree details { margin-left: 10px; font-size: 13px; }
    .tree summary, .tree button.leaf {
      cursor: pointer; padding: 4px 6px; border-radius: 4px; border: 0; background: transparent; text-align: left; width: 100%;
    }
    .tree summary:hover, .tree button.leaf:hover { background: var(--hover); }
    .hint { font-size: 11px; color: var(--muted); padding: 0 12px 12px; }
  </style>
</head>
<body>
  <header class="top">
    <div class="brand">
      <svg viewBox="0 0 64 64" fill="none">
        <path d="M32 4l6 10-6 10-6-10 6-10zm0 36l6 10-6 10-6-10 6-10zM4 32l10-6 10 6-10 6-10-6zm36 0l10-6 10 6-10 6-10-6zM14 14l12 2-2 12-12-2 2-12zm26 0l12-2 2 12-12 2-2-12zM14 50l12-2 2 12-12 2-2-12zm26 0l12 2-2 12-12-2 2-12z" fill="#29B5E8"/>
      </svg>
      Snowsight
    </div>
    <div class="search">Search (PoC — visual only)</div>
    <div class="user">
      <div>
        <div style="font-weight:600">UNIMED_ANALYST</div>
        <div style="color:var(--muted);font-size:11px">UNIMED_POC · ACCOUNTADMIN</div>
      </div>
      <div class="avatar">UA</div>
    </div>
  </header>
  <aside class="nav">
    <button data-view="home">Home</button>
    <div class="section">PROJECTS</div>
    <button class="active" data-view="worksheets">Worksheets</button>
    <button data-view="notebooks">Notebooks</button>
    <button data-view="dashboards">Dashboards</button>
    <div class="section">DATA</div>
    <button data-view="data">Databases</button>
    <button data-view="marketplace">Marketplace</button>
    <div class="section">MANAGE</div>
    <button data-view="monitoring">Monitoring</button>
    <button data-view="admin">Admin</button>
  </aside>
  <div class="drawer" id="drawer">
    <h3>Databases</h3>
    <p class="hint">ICEBERG = lakehouse no MinIO. POSTGRES = origem OLTP.</p>
    <div class="tree" id="tree">Carregando...</div>
  </div>
  <section class="main" id="worksheet">
    <div class="tabs">
      <button class="tab active">Worksheet 1</button>
      <button class="tab" disabled>+ New</button>
    </div>
    <div class="context">
      <span class="pill"><b>Role</b> ACCOUNTADMIN</span>
      <span class="pill"><b>Warehouse</b>
        <select id="wh" style="border:0;background:transparent">
          <option>COMPUTE_WH (XS)</option>
          <option>ANALYTICS_WH (M)</option>
          <option>LOADING_WH (S)</option>
        </select>
      </span>
      <span class="pill"><b>Database</b>
        <select id="db" style="border:0;background:transparent"></select>
      </span>
      <span class="pill"><b>Schema</b>
        <select id="schema" style="border:0;background:transparent"></select>
      </span>
    </div>
    <div class="toolbar">
      <button class="run" id="run">▶ Run</button>
      <button class="ghost" id="example">Sample query</button>
      <span class="meta" id="status">Pronto · Trino por baixo (simulacao visual do Snowsight)</span>
    </div>
    <div id="editor"></div>
    <div class="results">
      <div class="result-tabs">
        <span class="active">Results</span>
        <span>Chart</span>
        <span>Query Details</span>
        <span class="meta" id="stats"></span>
      </div>
      <div class="table-wrap" id="out"><div class="empty">Run a statement to see results.</div></div>
    </div>
  </section>
  <section class="main" id="placeholder" style="display:none;padding:32px">
    <h2 id="ph-title"></h2>
    <p style="color:var(--muted);max-width:640px">Esta area existe so para simular o Snowsight. Nesta PoC so Worksheets e Databases estao conectados ao Trino. Notebooks, Dashboards, Marketplace e Admin nao executam nada.</p>
  </section>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.32.6/ace.js"></script>
  <script>
    const editor = ace.edit("editor");
    editor.setTheme("ace/theme/textmate");
    editor.session.setMode("ace/mode/sql");
    editor.setValue("select *\nfrom postgres.cuidado_integrado.beneficiarios\nlimit 20;", -1);
    editor.setOptions({ fontSize: 13, showPrintMargin: false });

    const dbSel = document.getElementById("db");
    const schemaSel = document.getElementById("schema");
    const out = document.getElementById("out");
    const stats = document.getElementById("stats");
    const status = document.getElementById("status");

    async function api(path, opts) {
      const res = await fetch(path, opts);
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Falha na consulta");
      return data;
    }

    async function loadTree() {
      const data = await api("/api/tree");
      dbSel.innerHTML = data.catalogs.map(c => `<option>${c}</option>`).join("");
      if (data.catalogs.includes("iceberg")) dbSel.value = "iceberg";
      await loadSchemas();
      const root = document.getElementById("tree");
      root.innerHTML = "";
      for (const cat of data.tree) {
        const det = document.createElement("details");
        det.open = cat.name === "iceberg" || cat.name === "postgres";
        det.innerHTML = `<summary>${cat.name.toUpperCase()}</summary>`;
        for (const sch of cat.schemas) {
          const sdet = document.createElement("details");
          sdet.innerHTML = `<summary>${sch.name}</summary>`;
          for (const tbl of sch.tables) {
            const btn = document.createElement("button");
            btn.className = "leaf";
            btn.textContent = tbl;
            btn.onclick = () => {
              dbSel.value = cat.name;
              loadSchemas().then(() => { schemaSel.value = sch.name; });
              editor.setValue(`select *\nfrom ${cat.name}.${sch.name}.${tbl}\nlimit 100;`, -1);
            };
            sdet.appendChild(btn);
          }
          det.appendChild(sdet);
        }
        root.appendChild(det);
      }
    }

    async function loadSchemas() {
      const cat = dbSel.value;
      const data = await api("/api/schemas?catalog=" + encodeURIComponent(cat));
      schemaSel.innerHTML = data.schemas.map(s => `<option>${s}</option>`).join("");
    }

    dbSel.addEventListener("change", loadSchemas);

    async function runSql() {
      const sql = editor.getValue();
      document.getElementById("run").disabled = true;
      status.textContent = "Running on COMPUTE_WH...";
      stats.textContent = "";
      try {
        const data = await api("/api/query", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ sql, catalog: dbSel.value, schema: schemaSel.value })
        });
        if (!data.columns.length) {
          out.innerHTML = `<div class="empty">Statement succeeded. ${data.elapsed_ms} ms.</div>`;
        } else {
          const th = data.columns.map(c => `<th>${c}</th>`).join("");
          const tr = data.rows.map(r => `<tr>${r.map(v => `<td>${v === null ? "" : String(v)}</td>`).join("")}</tr>`).join("");
          out.innerHTML = `<table><thead><tr>${th}</tr></thead><tbody>${tr}</tbody></table>`;
        }
        stats.textContent = `${data.rows.length} rows · ${data.elapsed_ms} ms` + (data.truncated ? " · truncated" : "");
        status.textContent = "Succeeded · warehouse COMPUTE_WH";
      } catch (err) {
        out.innerHTML = `<div class="error">${err.message}</div>`;
        status.textContent = "Failed";
      } finally {
        document.getElementById("run").disabled = false;
      }
    }

    document.getElementById("run").onclick = runSql;
    document.getElementById("example").onclick = () => {
      editor.setValue("select *\nfrom iceberg.cuidado_integrado_ouro.mart_cuidado_integrado;", -1);
    };
    editor.commands.addCommand({ name: "run", bindKey: { win: "Ctrl-Enter", mac: "Command-Enter" }, exec: runSql });

    document.querySelectorAll(".nav button").forEach(btn => {
      btn.onclick = () => {
        document.querySelectorAll(".nav button").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        const view = btn.dataset.view;
        const drawer = document.getElementById("drawer");
        const ws = document.getElementById("worksheet");
        const ph = document.getElementById("placeholder");
        drawer.classList.toggle("open", view === "data");
        if (view === "worksheets" || view === "data") {
          ws.style.display = "grid";
          ph.style.display = "none";
        } else {
          ws.style.display = "none";
          ph.style.display = "block";
          document.getElementById("ph-title").textContent = btn.textContent;
        }
      };
    });

    loadTree().catch(err => {
      document.getElementById("tree").textContent = err.message;
      status.textContent = "Could not load catalogs";
    });
  </script>
</body>
</html>
"""


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        return

    def _json(self, payload, status=200):
        body = json.dumps(payload, default=json_default).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _html(self, body: bytes, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        qs = parse_qs(parsed.query)
        try:
            if path == "/":
                self._html(INDEX_HTML.encode("utf-8"))
            elif path == "/api/tree":
                tree = []
                cats = catalogs()
                for cat in cats:
                    sch_list = []
                    for sch in schemas(cat):
                        sch_list.append({"name": sch, "tables": tables(cat, sch)})
                    tree.append({"name": cat, "schemas": sch_list})
                self._json({"catalogs": cats, "tree": tree})
            elif path == "/api/schemas":
                cat = qs.get("catalog", ["iceberg"])[0]
                self._json({"schemas": schemas(cat)})
            elif path == "/api/columns":
                self._json(
                    {
                        "columns": columns(
                            qs.get("catalog", ["iceberg"])[0],
                            qs.get("schema", ["default"])[0],
                            qs.get("table", [""])[0],
                        )
                    }
                )
            else:
                self._json({"error": "not found"}, 404)
        except Exception:
            self._json({"error": traceback.format_exc()}, 500)

    def do_POST(self):
        if urlparse(self.path).path != "/api/query":
            self._json({"error": "not found"}, 404)
            return
        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length).decode("utf-8") or "{}"
        try:
            payload = json.loads(raw)
            sql = (payload.get("sql") or "").strip()
            if not sql:
                self._json({"error": "SQL vazio"}, 400)
                return
            result = fetch(
                sql,
                catalog=payload.get("catalog") or "iceberg",
                schema=payload.get("schema") or "default",
            )
            self._json(result)
        except Exception as exc:
            message = str(exc)
            self._json({"error": message}, 400)


def main() -> int:
    if sys.platform == "win32":
        try:
            sys.stdout.reconfigure(encoding="utf-8")
            sys.stderr.reconfigure(encoding="utf-8")
        except Exception:
            pass
    print(f"Snowsight (simulado): http://{HOST}:{PORT}  (Trino {TRINO_HOST}:{TRINO_PORT})", flush=True)
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
