#!/usr/bin/env bash
set -Eeuo pipefail

die() {
  printf '安装失败：%s\n' "$*" >&2
  exit 1
}

ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
VENV="$ROOT/.venv"
PYTHON="$VENV/bin/python"
MARKER="$VENV/.unified-marl-linux-cpu-py312"
MARKER_VALUE='unified-marl-0.7.0-linux-x86_64-cpu-py312-network-completion'

[[ "$(uname -s)" == 'Linux' ]] || die '仅支持 Linux x86_64。'
[[ "$(uname -m)" == 'x86_64' ]] || die '仅支持 x86_64 架构。'

SYSTEM_PYTHON="$(command -v python3.12 || true)"
[[ -n "$SYSTEM_PYTHON" ]] || die '需要预先安装 CPython 3.12，并确保 python3.12 位于 PATH。'
"$SYSTEM_PYTHON" -c 'import sys; raise SystemExit(0 if sys.implementation.name == "cpython" and sys.version_info[:2] == (3, 12) else 1)' \
  || die 'python3.12 必须是 CPython 3.12。'
"$SYSTEM_PYTHON" -m venv --help >/dev/null 2>&1 \
  || die '当前 Python 缺少 venv 模块；请预先安装 CPython 3.12 的 venv 支持。'
"$SYSTEM_PYTHON" -m pip --version >/dev/null 2>&1 \
  || die '当前 Python 缺少 pip；请预先安装 Python 3.12 pip。'
"$SYSTEM_PYTHON" -X utf8 -c 'import platform,re,sys; name,version=platform.libc_ver(); match=re.match(r"^(\d+)\.(\d+)", version); ok=(name == "glibc" and match is not None and tuple(map(int, match.groups())) >= (2, 28)); print("检测到 libc: {} {}".format(name or "unknown", version or "unknown")); raise SystemExit(0 if ok else 1)' \
  || die '需要 glibc 2.28 或更新版本；musl/Alpine 不在本包目标范围内。'

[[ -f "$ROOT/manifest.json" ]] || die '找不到 manifest.json。'
"$SYSTEM_PYTHON" -X utf8 -I "$ROOT/verify_bundle.py" \
  || die '文件清单校验失败；请重新从可信渠道取得 ZIP 并解压。'

if [[ -e "$VENV" || -L "$VENV" ]]; then
  [[ -d "$VENV" && ! -L "$VENV" ]] || die '.venv 已存在且不是普通目录；为安全起见停止安装。'
  [[ -f "$MARKER" ]] || die '.venv 已存在但没有本安装器标记；请换一个空目录解压后安装。'
  [[ "$(sed -n '1p' "$MARKER")" == "$MARKER_VALUE" && "$(sed -n '2p' "$MARKER")" == "$ROOT" ]] \
    || die '.venv 标记与本包路径或版本不匹配；请在新的解压目录安装。'
else
  mkdir -- "$VENV"
  printf '%s\n%s\n' "$MARKER_VALUE" "$ROOT" > "$MARKER"
fi

if [[ ! -x "$PYTHON" ]]; then
  "$SYSTEM_PYTHON" -m venv "$VENV" || die '创建隔离环境失败。'
fi
"$PYTHON" -X utf8 -I -c 'import pathlib,sys; expected=pathlib.Path(sys.argv[1]).resolve(); raise SystemExit(0 if sys.implementation.name == "cpython" and sys.version_info[:2] == (3, 12) and pathlib.Path(sys.prefix).resolve() == expected and sys.prefix != sys.base_prefix else 1)' "$VENV" \
  || die '.venv 不是可用的 CPython 3.12 隔离环境。'

env -u PIP_FIND_LINKS -u PIP_INDEX_URL -u PIP_EXTRA_INDEX_URL -u PIP_TRUSTED_HOST \
  PIP_CONFIG_FILE=/dev/null PIP_NO_INDEX=1 PIP_NO_CACHE_DIR=1 \
  "$PYTHON" -X utf8 -I -m pip install --disable-pip-version-check --no-index --no-cache-dir \
  --no-deps --only-binary=:all: --find-links="$ROOT/wheelhouse" --require-hashes \
  --requirement "$ROOT/requirements-local-linux-cpu.txt" \
  || die '本地锁定依赖安装失败；请检查 wheelhouse 文件并重新运行安装器。'
printf '即将从公开 PyPI 安装一个 Linux-only 依赖 hf-xet（版本范围 1.1.3 到 2.0.0 以下）；此步骤需要联网。\n'
env -u PIP_FIND_LINKS -u PIP_INDEX_URL -u PIP_EXTRA_INDEX_URL -u PIP_TRUSTED_HOST -u PIP_NO_INDEX \
  PIP_CONFIG_FILE=/dev/null PIP_NO_CACHE_DIR=1 \
  "$PYTHON" -X utf8 -I -m pip install --disable-pip-version-check --only-binary=:all: \
  --index-url https://pypi.org/simple --requirement "$ROOT/requirements-network.txt" \
  || die '联网补充 hf-xet 失败；请检查网络后重新运行安装器。'
env -u PIP_INDEX_URL -u PIP_EXTRA_INDEX_URL -u PIP_FIND_LINKS PIP_CONFIG_FILE=/dev/null PIP_NO_INDEX=1 "$PYTHON" -X utf8 -I -m pip check \
  || die 'pip check 发现依赖冲突。'
"$PYTHON" -X utf8 -I -c 'import gym, ml_collections, numpy, scipy, sklearn, torch, transformers, zmq, yaml; from unified_marl.algorithms.hmf import adapter; from unified_marl.algorithms.rghmf.modules import role_selectors; from unified_marl.rewards import service; import unified_marl; assert unified_marl.__version__ == "0.7.0"; assert torch.version.cuda is None; print("imports PASS; unified_marl={} torch={} device=cpu".format(unified_marl.__version__, torch.__version__))' \
  || die '核心或可选依赖导入失败。'

printf '安装完成。可选 CPU 冒烟测试：OUT="%s/results/smoke-$(date +%%Y%%m%%dT%%H%%M%%S)-$$"; mkdir -p "%s/results"; "%s/.venv/bin/python" -X utf8 -I "%s/smoke_test.py" --output "$OUT"\n' "$ROOT" "$ROOT" "$ROOT" "$ROOT"
printf '运行示例：bash "%s/run.sh" --help\n' "$ROOT"
