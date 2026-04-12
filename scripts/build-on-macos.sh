#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_OS="${TARGET_OS:-darwin}"
TARGET_CPU="${TARGET_CPU:-arm64}"
TARGET_NAME="${TARGET_OS}-${TARGET_CPU}"
PCP_DIR="${PCP_DIR:-/tmp/lazarus-build-station-example-${TARGET_NAME}}"
PROJECT_FILE="${PROJECT_FILE:-${ROOT_DIR}/app/lazarus_build_station_example.lpi}"
BGRABITMAP_PKG="${BGRABITMAP_PKG:-${ROOT_DIR}/components/bgrabitmap/bgrabitmap/bgrabitmappack.lpk}"
BGRACONTROLS_PKG="${BGRACONTROLS_PKG:-${ROOT_DIR}/components/bgracontrols/bgracontrols.lpk}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-${ROOT_DIR}/dist/${TARGET_NAME}}"
APP_BINARY="${ROOT_DIR}/app/lazarus_build_station_example"
LAZBUILD_BIN="${LAZBUILD_BIN:-$(command -v lazbuild || true)}"

if [[ -z "${LAZBUILD_BIN}" ]]; then
  echo "lazbuild not found in PATH" >&2
  exit 1
fi

if ! command -v fpc >/dev/null 2>&1; then
  echo "fpc not found in PATH" >&2
  exit 1
fi

case "${TARGET_OS}" in
  darwin) ;;
  *)
    echo "Unsupported TARGET_OS: ${TARGET_OS}" >&2
    exit 1
    ;;
esac

case "${TARGET_CPU}" in
  x86_64)
    FPC_CPU="x86_64"
    ;;
  arm64)
    FPC_CPU="aarch64"
    ;;
  *)
    echo "Unsupported TARGET_CPU: ${TARGET_CPU}" >&2
    exit 1
    ;;
esac

mkdir -p "${PCP_DIR}"
mkdir -p "${ARTIFACTS_DIR}"

LAZBUILD_ARGS=(--os=darwin --cpu="${FPC_CPU}" --ws=cocoa)
LAZBUILD_CMD=("${LAZBUILD_BIN}")

if [[ "$(uname -m)" == "arm64" ]] && file "${LAZBUILD_BIN}" | grep -q 'x86_64'; then
  LAZBUILD_CMD=(arch -x86_64 "${LAZBUILD_BIN}")
fi

echo "Building ${TARGET_NAME} from ${ROOT_DIR}"
echo "Using PCP_DIR=${PCP_DIR}"
echo "Using ARTIFACTS_DIR=${ARTIFACTS_DIR}"
echo "Using LAZBUILD_BIN=${LAZBUILD_BIN}"
echo "Using lazbuild args: ${LAZBUILD_ARGS[*]}"

build_pkg() {
  local pkg_path="$1"
  "${LAZBUILD_CMD[@]}" --pcp="${PCP_DIR}" "${LAZBUILD_ARGS[@]}" -B "${pkg_path}"
  "${LAZBUILD_CMD[@]}" --pcp="${PCP_DIR}" --add-package-link "${pkg_path}"
}

build_pkg "${BGRABITMAP_PKG}"
build_pkg "${BGRACONTROLS_PKG}"

set +e
"${LAZBUILD_CMD[@]}" --verbose --pcp="${PCP_DIR}" "${LAZBUILD_ARGS[@]}" -B "${PROJECT_FILE}"
build_status=$?
set -e

if [[ ${build_status} -ne 0 && "${TARGET_CPU}" == "arm64" && -f "${ROOT_DIR}/app/ppaslink.sh" ]]; then
  echo "Initial lazbuild failed for ${TARGET_NAME}; attempting fallback relink without legacy ld flags"
  cp "${ROOT_DIR}/app/ppaslink.sh" "${ROOT_DIR}/app/ppaslink-fallback.sh"
  python3 - <<'PY'
from pathlib import Path
path = Path("app/ppaslink-fallback.sh")
text = path.read_text()
text = text.replace(' -order_file /Users/runner/work/lazarus-build-station-example/lazarus-build-station-example/app/symbol_order.fpc', '')
text = text.replace(' -multiply_defined suppress', '')
text = text.replace('-macosx_version_min', '-macos_version_min')
path.write_text(text)
PY
  chmod +x "${ROOT_DIR}/app/ppaslink-fallback.sh"
  (cd "${ROOT_DIR}/app" && sh -x ./ppaslink-fallback.sh)
  build_status=0
fi

if [[ ${build_status} -ne 0 || ! -f "${APP_BINARY}" ]]; then
  echo "Expected build output not found or build failed: ${APP_BINARY}" >&2
  exit ${build_status:-1}
fi

cp "${APP_BINARY}" "${ARTIFACTS_DIR}/"
