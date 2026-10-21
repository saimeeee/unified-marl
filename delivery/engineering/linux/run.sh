#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
PYTHON="$ROOT/.venv/bin/python"
CLI="$ROOT/.venv/bin/unified-marl-app"

[[ "$(uname -s)" == 'Linux' ]] || { printf '仅支持 Linux。\n' >&2; exit 2; }
[[ "$(uname -m)" == 'x86_64' ]] || { printf '仅支持 x86_64 架构。\n' >&2; exit 2; }
[[ -x "$PYTHON" && -x "$CLI" ]] || { printf '请先运行 "%s/linux/install.sh"。\n' "$ROOT" >&2; exit 2; }
"$PYTHON" -X utf8 -I -c 'import pathlib,sys; expected=pathlib.Path(sys.argv[1]).resolve(); raise SystemExit(0 if sys.implementation.name=="cpython" and sys.version_info[:2]==(3,12) and pathlib.Path(sys.prefix).resolve()==expected and sys.prefix!=sys.base_prefix else 1)' "$ROOT/.venv" \
  || { printf '包内 .venv 不是可用的 CPython 3.12 隔离环境。\n' >&2; exit 2; }
exec "$CLI" "$@"
