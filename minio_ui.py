"""Navegador do bucket MinIO, usado no container (sobe com o start.py)."""

from __future__ import annotations

import html
import os
import sys
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, unquote, urlparse

from minio import Minio

HOST = os.environ.get("BIND_HOST", "0.0.0.0")
PORT = int(os.environ.get("PORT", "9001"))
BUCKET = os.environ.get("MINIO_BUCKET", "warehouse")
ENDPOINT = os.environ.get("MINIO_ENDPOINT", "localhost:9000")
ACCESS_KEY = os.environ.get("MINIO_ACCESS_KEY", "unimed")
SECRET_KEY = os.environ.get("MINIO_SECRET_KEY", "unimed123")


def get_client() -> Minio:
    return Minio(ENDPOINT, access_key=ACCESS_KEY, secret_key=SECRET_KEY, secure=False)


def wait_for_minio(timeout: int = 120) -> None:
    deadline = time.time() + timeout
    last_error = ""
    while time.time() < deadline:
        try:
            client = get_client()
            if client.bucket_exists(BUCKET):
                return
            last_error = f"bucket {BUCKET} ainda nao existe"
        except Exception as exc:
            last_error = str(exc)
        time.sleep(2)
    raise RuntimeError(f"MinIO nao ficou pronto: {last_error}")


def list_objects(prefix: str):
    client = get_client()
    folders = []
    files = []
    seen_folders = set()
    for obj in client.list_objects(BUCKET, prefix=prefix, recursive=False):
        name = obj.object_name[len(prefix) :] if obj.object_name.startswith(prefix) else obj.object_name
        if obj.is_dir or obj.object_name.endswith("/"):
            folder = prefix + name.split("/")[0] + "/"
            if folder not in seen_folders:
                seen_folders.add(folder)
                folders.append(folder)
        else:
            files.append(obj)
    return folders, files


def page(prefix: str = "", error: str | None = None) -> bytes:
    prefix = prefix.lstrip("/")
    crumbs = ['<a href="/">warehouse</a>']
    acc = ""
    for part in [p for p in prefix.split("/") if p]:
        acc += part + "/"
        crumbs.append(f'<a href="/?prefix={html.escape(acc)}">{html.escape(part)}</a>')
    rows = []
    err = f'<pre class="error">{html.escape(error)}</pre>' if error else ""
    try:
        folders, files = list_objects(prefix)
        for folder in folders:
            label = folder[len(prefix) :].rstrip("/")
            rows.append(
                f'<tr><td>pasta</td><td><a href="/?prefix={html.escape(folder)}">{html.escape(label)}/</a></td><td></td></tr>'
            )
        for obj in files:
            size = obj.size if obj.size is not None else 0
            rows.append(
                f"<tr><td>arquivo</td><td>{html.escape(obj.object_name)}</td><td>{size}</td></tr>"
            )
        if not rows:
            rows.append(
                "<tr><td colspan='3'>Bucket vazio. Os arquivos Parquet so aparecem depois do dbt run do modelo.</td></tr>"
            )
    except Exception as exc:
        err = f'<pre class="error">{html.escape(str(exc))}</pre>'

    body = f"""<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <title>PoC Unimed — MinIO</title>
  <style>
    :root {{ font-family: Segoe UI, sans-serif; background: #0f172a; color: #e2e8f0; }}
    body {{ margin: 0 auto; max-width: 1100px; padding: 24px; }}
    a {{ color: #93c5fd; }}
    table {{ border-collapse: collapse; width: 100%; background: #1e293b; border-radius: 8px; }}
    th, td {{ padding: 8px 10px; border-bottom: 1px solid #334155; text-align: left; }}
    .error {{ background: #450a0a; color: #fecaca; padding: 12px; border-radius: 8px; }}
    .sub {{ color: #94a3b8; }}
  </style>
</head>
<body>
  <h1>Bucket warehouse</h1>
  <p class="sub">MinIO sobe com o start.py e continua no Docker. Atualize a pagina depois de cada dbt run.</p>
  <p>{' / '.join(crumbs)}</p>
  {err}
  <table>
    <thead><tr><th>tipo</th><th>nome</th><th>bytes</th></tr></thead>
    <tbody>{''.join(rows)}</tbody>
  </table>
</body>
</html>"""
    return body.encode("utf-8")


class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        return

    def do_GET(self):
        parsed = urlparse(self.path)
        prefix = parse_qs(parsed.query).get("prefix", [""])[0]
        prefix = unquote(prefix)
        try:
            body = page(prefix)
            status = 200
        except Exception as exc:
            body = page(error=str(exc))
            status = 500
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
    wait_for_minio()
    print(f"Navegador MinIO: http://{HOST}:{PORT}")
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
