#!/usr/bin/env bash

# Script to format all JSON files in the current directory using jq.
# Adheres to Google's Shell Style Guide and CIM-compatible logging.

set -o errexit
set -o nounset
set -o pipefail

readonly SCRIPT_NAME="$(basename "$0")"

log() {
  local severity="$1"
  local message="$2"
  echo "time=$(date --iso-8601=seconds) script=${SCRIPT_NAME} severity=${severity} message=\"${message}\""
}

format_json_files() {
  # Ensure jq is installed
  if ! command -v jq &> /dev/null; then
    log "ERROR" "jq is not installed. Please install jq to use this script."
    exit 1
  fi

  # Find all .json files in the current directory
  shopt -s nullglob # Prevent wildcard from expanding if no matches
  json_files=( *.json )

  # Check if there are any .json files
  if [[ ${#json_files[@]} -eq 0 ]]; then
    log "INFO" "No JSON files found in the current directory."
    exit 0
  fi

  # Process each JSON file
  for json_file in $json_files; do
    log "INFO" "Processing json_file=${json_file}"
    if jq . "$json_file" > "${json_file}.tmp"; then
      mv "${json_file}.tmp" "$json_file"
      log "INFO" "Formatted json_file=${json_file} successfully."
    else
      log "ERROR" "Failed to format json_file=${json_file}. Skipping."
      rm -f "${json_file}.tmp" # Clean up temporary file on failure
    fi
  done
}

main() {
  log "INFO" "Starting script execution."
  format_json_files
  log "INFO" "Script execution completed."
}

main "$@"
