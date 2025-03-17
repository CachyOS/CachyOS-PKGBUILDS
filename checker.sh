#!/bin/bash
set -o nounset -o errexit -o pipefail

# see https://gitlab.archlinux.org/archlinux/nvchecker-poc
GITHUB_TOKEN="${GITHUB_TOKEN:?GITHUB_TOKEN not set (config file or environment)}"
GITHUB_REPO="${GITHUB_REPO:?GITHUB_REPO not set (config file or environment)}"

# --- GitHub API Helper Function ---
github_api() {
  local method="${1}"
  local endpoint="${2}"
  local data="${3}"

  local url="https://api.github.com/repos/${GITHUB_REPO}/${endpoint}"

  curl -sSf \
    --request "${method}" \
    --header "Authorization: token ${GITHUB_TOKEN}" \
    --header "Accept: application/vnd.github+json" \
    --header "X-GitHub-Api-Version: 2022-11-28" \
    "${url}" \
    ${data:+--data "${data}"}
}

# --- GitHub Issue Functions ---
create_issue() {
  local package="${1}"
  local title="${2}"
  local description="${3}"

  local issue_data='{"title": "'"${title}"'", "body": "'"${description}"'", "labels": ["out-of-date"]}'
  github_api POST "issues" "${issue_data}" >/dev/null
  echo "Created issue for ${package}: ${title}"
}

update_issue() {
  local issue_number="${1}"
  local title="${2}"
  local description="${3}"

  local issue_data='{"title": "'"${title}"'", "body": "'"${description}"'"}'
  github_api PATCH "issues/${issue_number}" "${issue_data}" >/dev/null
  echo "Updated issue #${issue_number} with title: ${title}"
}

comment_on_issue() {
  local issue_number="${1}"
  local body="${2}"

  local comment_data='{"body": "'"${body}"'"}'
  github_api POST "issues/${issue_number}/comments" "${comment_data}" >/dev/null
  echo "Commented on issue #${issue_number}"
}

close_issue() {
  local issue_number="${1}"
  local body="${2}"

  local issue_data='{"state": "closed"}'
  github_api PATCH "issues/${issue_number}" "${issue_data}" >/dev/null
  comment_on_issue "${issue_number}" "${body}"
  echo "Closed issue #${issue_number}"
}


find_existing_issue() {
  local package="${1}"
  local search_title="${package}: "

  local issues_json="$(github_api GET "issues?state=open&labels=out-of-date&sort=created&direction=asc&per_page=100")"
  local issue_number="$(jq -r ".[] | select(.title | startswith(\"${search_title}\")) | .number" <<< "${issues_json}")"

  if [[ -n "${issue_number}" ]]; then
    echo "${issue_number}"
  fi
}


# --- Package Checking Functions (Core Logic from Original Script) ---
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
    issue_number="$(find_existing_issue "${pkgbase}")"
    if [[ -n "${issue_number}" ]]; then
      echo "${pkgbase}: current version ${pkgver} is latest, closing existing issue #${issue_number}"
      close_issue "${issue_number}" "Current version ${pkgver} is latest, closing the issue."
    fi

  elif (( result > 0 )); then
    echo "${pkgbase}: upgrade from version ${pkgver} to ${upstream_version}"
    title="${pkgbase}: new version ${upstream_version}"
    description="New upstream version ${upstream_version} is available for package ${pkgbase}.\n\nCurrent version: ${pkgver}\nUpstream version: ${upstream_version}\n\nPlease update the package."

    issue_number="$(find_existing_issue "${pkgbase}")"
    if [[ -n "${issue_number}" ]]; then
      # Check if the issue is for the *same* upstream version (to avoid redundant updates)
      issue_title="$(github_api GET "issues/${issue_number}" | jq -r ".title")"
      if [[ "${issue_title}" != "${title}" ]]; then
        update_issue "${issue_number}" "${title}" "${description}"
      else
        echo "Issue #${issue_number} already exists for version ${upstream_version} of ${pkgbase}, skipping update."
      fi
    else
      create_issue "${pkgbase}" "${title}" "${description}"
    fi
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

# --- Main execution ---
pkgbuilds_dir="$1"
if [[ -z "${pkgbuilds_dir}" ]]; then
  echo "Usage: $0 <pkgbuilds_directory>"
  exit 1
fi

check_packages "${pkgbuilds_dir}"

echo "Package checks and GitHub issue updates completed."
