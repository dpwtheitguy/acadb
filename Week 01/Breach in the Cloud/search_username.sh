#!/usr/bin/env bash

# Description: This script searches for userName in files within the specified directory, 
# sorts the results, and logs the output in a secure and organized manner.

# Security: Exit on errors, unset variables, and disallow globbing.
set -euf -o pipefail
set -r

# Default directory to search (current directory if not provided)
declare search_directory="${1:-.}"  # Use the first argument or default to current directory
declare search_term="userName"

# Default output file (current directory if not provided)
declare output_file="${2:-./output.log}"  # Use the second argument or default to ./output.log

# Function to write logs
function write-log() {
  local severity="$1"
  shift
  # Log to console and system logger (logger command) for centralized logging.
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [$severity] $*" >&2
  logger "[$severity] $*"
}

# Function to search for userName and log results
function search-and-log() {
  if [[ ! -d "$search_directory" ]]; then
    write-log "ERROR" "Directory $search_directory does not exist."
    exit 1
  fi

  write-log "INFO" "Starting search for '$search_term' in $search_directory..."

  # Perform the search and sort results
  results=$(grep -r -- "$search_term" "$search_directory" | sort -u)

  # Check if there are any results
  if [[ -z "$results" ]]; then
    write-log "INFO" "No occurrences of '$search_term' found in $search_directory."
  else
    write-log "INFO" "Search results for '$search_term' found in $search_directory."
    # Use tee for output redirection to safely write results
    echo "$results" | tee "$output_file" > /dev/null
    write-log "INFO" "Results written to $output_file."
  fi
}

# Main function to execute the search
function main() {
  search-and-log
}

main "$@"
