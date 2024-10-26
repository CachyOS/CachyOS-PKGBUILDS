#!/bin/bash
set -o nounset -o errexit -o pipefail

# see https://gitlab.archlinux.org/archlinux/nvchecker-poc

check_package() {
  # path to folder which contains package files (e.g .SRCINFO, PKGBUILD, .nvchecker.toml)
  local package="${1}"

  nvchecker_content="$(cat "${package}/.nvchecker.toml" 2>/dev/null)"
  if [ $? -ne 0 ]; then
    echo "No .nvchecker.toml file found for ${package}, skipping.."
    return
  fi
  nvchecker_output="$(nvchecker -c <(echo "${nvchecker_content}") --logger json)"
  upstream_version="$(jq -r 'select((.level != "debug") and (.event != "ignoring invalid version")) | .version' <<< "${nvchecker_output}")"
  srcinfo_content="$(cat "${package}/.SRCINFO" 2>/dev/null)"
  if [ $? -ne 0 ]; then
    echo "No .SRCINFO file found for ${package}, skipping.."
    return
  fi
  pkgver="$(awk '/pkgver/ {print $3}' <<< "${srcinfo_content}")"
  pkgbase="$(awk '/pkgbase/ {print $3}' <<< "${srcinfo_content}")"
  result="$(vercmp "${upstream_version}" "${pkgver}")"
  if (( result == 0 )); then
    echo "${pkgbase}: current version ${pkgver} is latest"
  elif (( result > 0 )); then
    echo "${pkgbase}: upgrade from version ${pkgver} to ${upstream_version}"
  fi
}

check_package_wrap() {
  # path to .nvchecker.toml
  local package="${1}"
  local package_dir="$(dirname ${package})"

  check_package "${package_dir}"
}

check_packages() {
  local pkgbuilds_dir="${1}"

  shopt -s globstar
  for package in "${pkgbuilds_dir}"/**/.nvchecker.toml; do
    if ! check_package_wrap "${package}"; then
      echo "Error checking package ${package}"
    fi
  done
}

pkgbuilds_dir="$1"
check_packages "${pkgbuilds_dir}"
