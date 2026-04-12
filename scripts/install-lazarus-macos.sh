#!/usr/bin/env bash
set -euo pipefail

LAZARUS_VERSION="${LAZARUS_VERSION:-3.6}"
LAZARUS_PKG_URL="${LAZARUS_PKG_URL:-https://download.lazarus-ide.org/Lazarus%20macOS%20x86-64/Lazarus%20${LAZARUS_VERSION}/Lazarus-${LAZARUS_VERSION}-macosx-x86_64.pkg}"
RUNNER_ARCH="$(uname -m)"
PKG_PATH="${RUNNER_TEMP:-/tmp}/Lazarus-${LAZARUS_VERSION}-macosx-x86_64.pkg"

brew update
brew install fpc

if [[ "${RUNNER_ARCH}" == "arm64" ]]; then
  softwareupdate --install-rosetta --agree-to-license || true
fi

curl -fL "${LAZARUS_PKG_URL}" -o "${PKG_PATH}"
sudo installer -pkg "${PKG_PATH}" -target /

LAZBUILD_BIN="$(find /Applications /usr/local -name lazbuild -type f 2>/dev/null | sort | head -n 1)"
if [[ -z "${LAZBUILD_BIN}" ]]; then
  echo "Unable to locate lazbuild after Lazarus installation" >&2
  exit 1
fi
echo "Using lazbuild at ${LAZBUILD_BIN}"
file "${LAZBUILD_BIN}"

if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "LAZBUILD_BIN=${LAZBUILD_BIN}" >> "${GITHUB_ENV}"
fi
