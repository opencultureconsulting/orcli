#!/bin/bash
# Run orcli's tests with several OpenRefine releases.
#
# Usage:
#   ./test-versions.sh [VERSION...]    (default: the supported releases below)
#
# Downloads each OpenRefine release (Linux) once into ${ORCLI_CACHE}
# (default: ~/.cache/orcli), copies ./orcli and tests/ next to it and runs
# `orcli test` there. Requires Java and a free port 3333.

set -uo pipefail

versions=("$@")
if [[ ${#versions[@]} -eq 0 ]]; then
  versions=(3.7.9 3.8.7 3.9.5 3.10.1)
fi
cache="${ORCLI_CACHE:-${XDG_CACHE_HOME:-${HOME}/.cache}/orcli}"
repo="$(cd "$(dirname "$0")" && pwd)"
failed=()

for version in "${versions[@]}"; do
  dir="${cache}/openrefine-${version}"
  if [[ ! -x "${dir}/refine" ]]; then
    echo "downloading OpenRefine ${version}..." >&2
    mkdir -p "${dir}"
    if ! curl -fsSL "https://github.com/OpenRefine/OpenRefine/releases/download/${version}/openrefine-linux-${version}.tar.gz" |
      tar -xz --strip 1 -C "${dir}"; then
      echo "download of OpenRefine ${version} failed!" >&2
      rm -rf "${dir}"
      failed+=("${version}")
      continue
    fi
  fi
  cp "${repo}/orcli" "${dir}/"
  rm -rf "${dir}/tests"
  cp -r "${repo}/tests" "${dir}/"
  echo "=== OpenRefine ${version}"
  if ! "${dir}/orcli" test; then
    failed+=("${version}")
  fi
done

if [[ ${#failed[@]} -gt 0 ]]; then
  echo "=== tests failed with OpenRefine ${failed[*]}" >&2
  exit 1
fi
echo "=== tests passed with OpenRefine ${versions[*]}"
