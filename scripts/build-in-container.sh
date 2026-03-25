#!/usr/bin/env bash
set -euo pipefail

TARGET_OS="${TARGET_OS:-linux}"
TARGET_CPU="${TARGET_CPU:-x86_64}"
TARGET_NAME="${TARGET_OS}-${TARGET_CPU}"
PCP_DIR="${PCP_DIR:-/tmp/lazarus-build-station-example-${TARGET_NAME}}"
PROJECT_FILE="${PROJECT_FILE:-/workspace/app/lazarus_build_station_example.lpi}"
BGRABITMAP_PKG="${BGRABITMAP_PKG:-/workspace/components/bgrabitmap/bgrabitmap/bgrabitmappack.lpk}"
BGRACONTROLS_PKG="${BGRACONTROLS_PKG:-/workspace/components/bgracontrols/bgracontrols.lpk}"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-/workspace/dist/${TARGET_NAME}}"

mkdir -p "${PCP_DIR}"
mkdir -p "${ARTIFACTS_DIR}"

LAZBUILD_ARGS=()
if [[ "${TARGET_OS}" == win32 || "${TARGET_OS}" == win64 ]]; then
  LAZBUILD_ARGS+=(--os="${TARGET_OS}" --ws=win32)
fi

build_pkg() {
  local pkg_path="$1"
  lazbuild --pcp="${PCP_DIR}" "${LAZBUILD_ARGS[@]}" -B "${pkg_path}" >/dev/null
  lazbuild --pcp="${PCP_DIR}" --add-package-link "${pkg_path}" >/dev/null
}

build_pkg "${BGRABITMAP_PKG}"
build_pkg "${BGRACONTROLS_PKG}"

lazbuild --pcp="${PCP_DIR}" "${LAZBUILD_ARGS[@]}" -B "${PROJECT_FILE}"

if [[ "${TARGET_OS}" == win* ]]; then
  cp /workspace/app/lazarus_build_station_example.exe "${ARTIFACTS_DIR}/"
else
  cp /workspace/app/lazarus_build_station_example "${ARTIFACTS_DIR}/"
fi
