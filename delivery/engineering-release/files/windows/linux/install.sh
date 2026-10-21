#!/usr/bin/env bash
set -Eeuo pipefail

die() {
  printf '安装失败：%s\n' "$*" >&2
  exit 1
}

FEATURE='core'
while (($#)); do
  case "$1" in
    --Feature|--feature)
      (($# >= 2)) || die '需要在 --Feature 后指定功能。'
      FEATURE="$2"
      shift 2
      ;;
    --help|-h)
      printf '用法：bash linux/install.sh [--Feature core|warehouse|warehouse-role|traffic|powergrid|reward|role|hmf|distributed]\n'
      exit 0
      ;;
    *) die "未知安装参数：$1" ;;
  esac
done
case "$FEATURE" in
  core|warehouse|warehouse-role|traffic|powergrid|reward|role|hmf|distributed) ;;
  *) die "不支持的功能：$FEATURE" ;;
esac

ROOT="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
VENV="$ROOT/.venv"
PYTHON="$VENV/bin/python"
MARKER="$VENV/.unified-marl-engineering-linux-py312"
MARKER_VALUE='unified-marl-0.8.0-linux-x86_64-cpu-py312-engineering'

[[ "$(uname -s)" == 'Linux' ]] || die '仅支持 Linux。'
[[ "$(uname -m)" == 'x86_64' ]] || die '仅支持 x86_64 架构。'
SYSTEM_PYTHON="$(command -v python3.12 || true)"
[[ -n "$SYSTEM_PYTHON" ]] || die '需要预先安装 CPython 3.12，并确保 python3.12 位于 PATH。'
"$SYSTEM_PYTHON" -c 'import sys; raise SystemExit(0 if sys.implementation.name == "cpython" and sys.version_info[:2] == (3, 12) else 1)' \
  || die '需要 CPython 3.12。'
"$SYSTEM_PYTHON" -m venv --help >/dev/null 2>&1 || die '当前 Python 缺少 venv 模块。'
"$SYSTEM_PYTHON" -m pip --version >/dev/null 2>&1 || die '当前 Python 缺少 pip。'
"$SYSTEM_PYTHON" -X utf8 -c 'import platform,re; name,version=platform.libc_ver(); match=re.match(r"^(\d+)\.(\d+)",version); ok=name=="glibc" and match and tuple(map(int,match.groups())) >= (2,28); print("检测到 libc: {} {}".format(name or "unknown",version or "unknown")); raise SystemExit(0 if ok else 1)' \
  || die '需要 glibc 2.28 或更新版本；musl/Alpine 不在本包目标范围内。'

[[ -f "$ROOT/manifest.json" ]] || die '找不到 manifest.json。'
"$SYSTEM_PYTHON" -X utf8 -I "$ROOT/verify_bundle.py" || die '文件清单校验失败。'

if [[ -e "$VENV" || -L "$VENV" ]]; then
  [[ -d "$VENV" && ! -L "$VENV" ]] || die '.venv 已存在且不是普通目录。'
  [[ -f "$MARKER" ]] || die '.venv 已存在但没有工程包安装标记；请在新目录解压。'
  [[ "$(sed -n '1p' "$MARKER")" == "$MARKER_VALUE" && "$(sed -n '2p' "$MARKER")" == "$ROOT" ]] \
    || die '.venv 标记与本包版本或路径不匹配；请在新目录解压。'
else
  mkdir -- "$VENV"
  printf '%s\n%s\n' "$MARKER_VALUE" "$ROOT" > "$MARKER"
fi
if [[ ! -x "$PYTHON" ]]; then
  "$SYSTEM_PYTHON" -m venv "$VENV" || die '创建隔离环境失败。'
fi
"$PYTHON" -X utf8 -I -c 'import pathlib,sys; expected=pathlib.Path(sys.argv[1]).resolve(); raise SystemExit(0 if sys.implementation.name=="cpython" and sys.version_info[:2]==(3,12) and pathlib.Path(sys.prefix).resolve()==expected and sys.prefix!=sys.base_prefix else 1)' "$VENV" \
  || die '.venv 不是可用的 CPython 3.12 隔离环境。'

install_local_lock() {
  local lock_file="$1"
  [[ -f "$lock_file" ]] || die "找不到所选功能的锁文件：$lock_file"
  env -u PIP_FIND_LINKS -u PIP_INDEX_URL -u PIP_EXTRA_INDEX_URL -u PIP_TRUSTED_HOST \
    PIP_CONFIG_FILE=/dev/null PIP_NO_INDEX=1 PIP_NO_CACHE_DIR=1 PIP_NO_INPUT=1 \
    "$PYTHON" -X utf8 -I -m pip install --disable-pip-version-check --no-index --no-cache-dir \
    --no-deps --only-binary=:all: --find-links="$ROOT/wheelhouse" --require-hashes \
    --requirement "$lock_file" || die "本地锁定依赖安装失败：$lock_file"
}

install_local_lock "$ROOT/requirements-core-linux.txt"
case "$FEATURE" in
  warehouse)
    install_local_lock "$ROOT/requirements-hmf-linux.txt"
    ;;
  warehouse-role)
    install_local_lock "$ROOT/requirements-hmf-linux.txt"
    install_local_lock "$ROOT/requirements-role-linux.txt"
    ;;
  reward|role|hmf|distributed)
    install_local_lock "$ROOT/requirements-$FEATURE-linux.txt"
    network_file="$ROOT/requirements-network-$FEATURE.txt"
    if [[ -f "$network_file" ]]; then
      env -u PIP_FIND_LINKS -u PIP_INDEX_URL -u PIP_EXTRA_INDEX_URL -u PIP_TRUSTED_HOST -u PIP_NO_INDEX \
        PIP_CONFIG_FILE=/dev/null PIP_NO_CACHE_DIR=1 PIP_NO_INPUT=1 \
        "$PYTHON" -X utf8 -I -m pip install --disable-pip-version-check --only-binary=:all: \
        --index-url https://pypi.org/simple --requirement "$network_file" \
        || die "所选功能的联网补充依赖安装失败：$network_file"
    fi
    ;;
  powergrid)
    install_local_lock "$ROOT/requirements-hmf-linux.txt"
    app_requirements="$ROOT/requirements-powergrid.txt"
    [[ -f "$app_requirements" ]] || die '包内没有 requirements-powergrid.txt；请按 docs/POWERGRID_GUIDE.md 安装 pandapower 功能。'
    env -u PIP_FIND_LINKS -u PIP_INDEX_URL -u PIP_EXTRA_INDEX_URL -u PIP_TRUSTED_HOST -u PIP_NO_INDEX \
      PIP_CONFIG_FILE=/dev/null PIP_NO_CACHE_DIR=1 PIP_NO_INPUT=1 \
      "$PYTHON" -X utf8 -I -m pip install --disable-pip-version-check --find-links="$ROOT/wheelhouse" \
      --index-url https://pypi.org/simple --requirement "$app_requirements" \
      || die 'pandapower 功能联网安装失败。'
    ;;
  *) ;;
esac

"$PYTHON" -X utf8 -I -m pip check || die 'pip check 发现依赖冲突或缺项。'
"$PYTHON" -X utf8 -I -c 'import unified_marl; assert unified_marl.__version__ == "0.8.0"; print("Installed unified_marl=" + unified_marl.__version__)' \
  || die 'unified-marl 导入检查失败。'
if [[ "$FEATURE" == 'traffic' ]]; then
  printf 'CityFlow 由用户从外部源码构建；请查看 docs/TRAFFIC_GUIDE.md。未下载交通模拟器。\n'
fi
printf '安装完成。没有启动训练、仿真或实验。运行示例：bash "%s/linux/run.sh" --help\n' "$ROOT"
