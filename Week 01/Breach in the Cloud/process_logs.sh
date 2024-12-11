#!/usr/bin/env bash

# Script is useful for cleaning up Cloudtrail logs for investigations

set -o errexit
set -o nounset
set -o pipefail

readonly SCRIPT_NAME="$(basename "$0")"

log() {
  local severity="$1"
  local message="$2"
  echo "time=$(date --iso-8601=seconds) script=${SCRIPT_NAME} severity=${severity} message=\"${message}\"" app=\"${app}\"" pwd=\"${pwd}\""
}

format_json_files() {
  # Ensure jq is installed
  if ! command -v jq &> /dev/null; then
    log "ERROR" "app=jq status=missing. Install package=jq and add to path."
    exit 1
  fi

  # Find all .json files in the current directory
  shopt -s nullglob # Prevent wildcard from expanding if no matches
  json_files=( *.json )

  # Check if there are any .json files
  if [[ ${#json_files[@]} -eq 0 ]]; then
    log "INFO" "file_type=JSON files status=missing in current directory"
    exit 0
  fi

  # Process each JSON file
  for json_file in $json_files; do
    log "INFO" "Processing json_file=${json_file}"
    if jq . "$json_file" > "${json_file}.tmp"; then
      mv "${json_file}.tmp" "$json_file"
      log "INFO" "Formatted json_file=${json_file} status=success"
    else
      log "ERROR" "status=failed to format json_file=${json_file}. action=skip"
      rm -f "${json_file}.tmp" # Clean up temporary file on failure
    fi
  done
}

main() {
  log "INFO" "action=starting script"
  format_json_files
  log "INFO" "action=completed script"
}

main "$@"
