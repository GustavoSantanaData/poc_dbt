"""Sobe a PoC Unimed (Postgres + MinIO + Trino) e opcionalmente roda o dbt."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import socket
import subprocess
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent

if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

WAREHOUSE_SCHEMAS = [
    ("default", "s3://warehouse/default"),
    ("cuidado_integrado_bronze", "s3://warehouse/cuidado_integrado/bronze"),
    ("cuidado_integrado_prata", "s3://warehouse/cuidado_integrado/prata"),
    ("cuidado_integrado_ouro", "s3://warehouse/cuidado_integrado/ouro"),
    ("resultados_exames_bronze", "s3://warehouse/resultados_exames/bronze"),
    ("resultados_exames_prata", "s3://warehouse/resultados_exames/prata"),
    ("resultados_exames_ouro", "s3://warehouse/resultados_exames/ouro"),
    ("autorizacoes_bronze", "s3://warehouse/autorizacoes/bronze"),
    ("autorizacoes_prata", "s3://warehouse/autorizacoes/prata"),
    ("autorizacoes_ouro", "s3://warehouse/autorizacoes/ouro"),
    ("faturamento_bronze", "s3://warehouse/faturamento/bronze"),
    ("faturamento_prata", "s3://warehouse/faturamento/prata"),
    ("faturamento_ouro", "s3://warehouse/faturamento/ouro"),
]


def log(message: str) -> None:
    print(f"[poc] {message}", flush=True)


def _known_docker_locations() -> list[Path]:
    """Locais padrao do Docker em qualquer maquina, sem path de usuario fixo."""
    exe = "docker.exe" if sys.platform == "win32" else "docker"
    local_app = os.environ.get("LOCALAPPDATA", str(Path.home() / "AppData" / "Local"))
    program_files = os.environ.get("ProgramFiles", r"C:\Program Files")
    program_files_x86 = os.environ.get("ProgramFiles(x86)", r"C:\Program Files (x86)")
    return [
        Path(local_app) / "Programs" / "DockerDesktop" / "resources" / "bin" / exe,
        Path(program_files) / "Docker" / "Docker" / "resources" / "bin" / exe,
        Path(program_files_x86) / "Docker" / "Docker" / "resources" / "bin" / exe,
        Path.home() / ".docker" / "bin" / exe,
        Path("/usr/local/bin") / exe,
        Path("/opt/homebrew/bin") / exe,
        Path("/usr/bin") / exe,
    ]


def _docker_next_to_desktop(desktop_exe: Path) -> Path | None:
    for relative in (
        Path("resources") / "bin" / "docker.exe",
        Path("resources") / "bin" / "docker",
        Path("bin") / "docker.exe",
        Path("bin") / "docker",
    ):
        candidate = desktop_exe.parent / relative
        if candidate.exists():
            return candidate
    return None


def _docker_from_running_desktop() -> Path | None:
    """Se o Docker Desktop estiver aberto, descobre o CLI ao lado do app."""
    if sys.platform != "win32":
        return None
    try:
        completed = subprocess.run(
            [
                "powershell",
                "-NoProfile",
                "-Command",
                "(Get-Process 'Docker Desktop' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Path)",
            ],
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        return None
    desktop_path = completed.stdout.strip().strip('"')
    if not desktop_path:
        return None
    return _docker_next_to_desktop(Path(desktop_path))


def find_docker() -> str:
    override = os.environ.get("DOCKER_BIN")
    if override:
        if Path(override).exists():
            return override
        raise RuntimeError(f"DOCKER_BIN aponta para um arquivo inexistente: {override}")

    found = shutil.which("docker")
    if found:
        return found

    for candidate in _known_docker_locations():
        if candidate.exists():
            return str(candidate)

    from_desktop = _docker_from_running_desktop()
    if from_desktop is not None:
        return str(from_desktop)

    raise RuntimeError(
        "Docker nao encontrado no PATH nem nos locais padrao de instalacao. "
        "Instale o Docker Desktop, deixe-o em execucao e abra um novo terminal. "
        "Se o CLI estiver em outro lugar, defina DOCKER_BIN com o caminho do docker."
    )


def compose(*args: str, check: bool = True) -> subprocess.CompletedProcess:
    docker = find_docker()
    docker_bin = str(Path(docker).parent)
    env = os.environ.copy()
    env["PATH"] = docker_bin + os.pathsep + env.get("PATH", "")
    return subprocess.run([docker, "compose", *args], cwd=ROOT, check=check, env=env)


def wait_port(host: str, port: int, timeout: int, label: str) -> None:
    log(f"Aguardando {label} em {host}:{port}...")
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            with socket.create_connection((host, port), timeout=2):
                log(f"{label} respondeu na porta {port}.")
                return
        except OSError:
            time.sleep(2)
    raise RuntimeError(f"Timeout esperando {label} em {host}:{port}")


def wait_trino(timeout: int = 180) -> None:
    url = "http://localhost:8080/v1/info"
    log("Aguardando o Trino sair do modo starting...")
    deadline = time.time() + timeout
    last_error = "sem resposta"
    while time.time() < deadline:
        try:
            with urllib.request.urlopen(url, timeout=3) as response:
                payload = json.loads(response.read().decode("utf-8"))
                if payload.get("starting") is False:
                    log("Trino pronto.")
                    return
                last_error = "ainda em starting=true"
        except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as exc:
            last_error = str(exc)
        time.sleep(3)
    raise RuntimeError(f"Timeout esperando o Trino. Ultimo status: {last_error}")


def seed_postgres() -> None:
    log("Recarregando schemas, tabelas e dados de exemplo no Postgres...")
    for script in ("01_schemas.sql", "02_tables.sql", "03_seed.sql"):
        compose(
            "exec",
            "-T",
            "postgres",
            "psql",
            "-U",
            "unimed",
            "-d",
            "unimed",
            "-v",
            "ON_ERROR_STOP=1",
            "-f",
            f"/docker-entrypoint-initdb.d/{script}",
        )


def trino_execute(sql: str) -> None:
    from trino.dbapi import connect

    conn = connect(
        host="localhost",
        port=8080,
        user="dbt",
        catalog="iceberg",
        schema="information_schema",
        http_scheme="http",
    )
    try:
        cursor = conn.cursor()
        cursor.execute(sql)
        try:
            cursor.fetchall()
        except Exception:
            pass
    finally:
        conn.close()


def create_warehouse_schemas() -> None:
    log("Criando schemas Iceberg no warehouse (MinIO)...")
    catalogs = []
    from trino.dbapi import connect

    conn = connect(host="localhost", port=8080, user="dbt", http_scheme="http")
    try:
        cursor = conn.cursor()
        cursor.execute("show catalogs")
        catalogs = [row[0] for row in cursor.fetchall()]
    finally:
        conn.close()

    if "iceberg" not in catalogs or "postgres" not in catalogs:
        raise RuntimeError(
            f"Catalogos esperados nao apareceram no Trino. Encontrados: {catalogs}"
        )

    for schema_name, location in WAREHOUSE_SCHEMAS:
        trino_execute(
            f"create schema if not exists iceberg.{schema_name} "
            f"with (location = '{location}')"
        )
    log("Schemas do lakehouse criados.")


def print_summary() -> None:
    print(
        """
============================================================
PoC Unimed pronta
============================================================
Origem OLTP (Postgres)
  host: localhost  porta: 5433
  database: unimed  user: unimed  senha: unimed

Object storage (MinIO)
  API:     http://localhost:9000
  Browser: http://localhost:9001  (sobe no Docker, nao precisa rodar python)
  user: unimed  senha: unimed123
  bucket: warehouse (vazio ate o dbt run gravar as tabelas)

Warehouse SQL (Trino)
  Painel do cluster (metricas): http://localhost:8080
  Console SQL no navegador:     python sql_ui.py  ->  http://localhost:8501
  host: localhost  porta: 8080  catalogo: iceberg
  user: dbt (sem senha)

Consultar a origem (Postgres via Trino):
  select * from postgres.cuidado_integrado.beneficiarios;

Quando quiser materializar bronze/prata/ouro no MinIO:
  dbt run --profiles-dir . --project-dir .

Depois disso, consultar um datamart:
  python consultas.py

Parar o ambiente:
  python start.py down
============================================================
"""
    )


def up() -> None:
    docker = find_docker()
    log(f"Usando Docker: {docker}")
    log("Subindo Postgres, MinIO, Iceberg REST e Trino...")
    compose("up", "-d", "--build")
    wait_port("localhost", 5433, 90, "Postgres")
    wait_port("localhost", 9000, 90, "MinIO")
    wait_port("localhost", 9001, 90, "MinIO browser")
    wait_port("localhost", 8181, 90, "Iceberg REST")
    wait_trino()
    seed_postgres()
    create_warehouse_schemas()
    print_summary()


def down() -> None:
    log("Derrubando os containers...")
    compose("down")
    log("Ambiente parado. Os volumes foram mantidos.")


def main() -> int:
    parser = argparse.ArgumentParser(description="Bootstrap da PoC dbt + lakehouse Unimed")
    parser.add_argument("action", nargs="?", default="up", choices=["up", "down"])
    args = parser.parse_args()
    try:
        if args.action == "down":
            down()
        else:
            up()
    except subprocess.CalledProcessError as exc:
        log(f"Comando falhou com codigo {exc.returncode}.")
        return exc.returncode or 1
    except Exception as exc:
        log(f"Erro: {exc}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
