#!/bin/bash

# See: https://pwnedlabs.io/labs/breach-in-the-cloud
# Script to format all JSON files in the current directory using jq
# It overwrites the original files with the formatted version.
# Common use case it to clean up CloudTrail Logs

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install jq to use this script."
  exit 1
fi

# Iterate over all .json files in the current directory
for file in *.json; do
  # Check if the file exists (in case there are no .json files)
  if [[ ! -e "$file" ]]; then
    echo "No JSON files found in the current directory."
    exit 0
  fi

  # Format the file using jq and create a temporary file
  if jq . "$file" > "$file.tmp"; then
    # Overwrite the original file with the formatted file
    mv "$file.tmp" "$file"
    echo "Formatted: $file"
  else
    # Handle jq errors
    echo "Error: Failed to format $file. Skipping."
    rm -f "$file.tmp" # Clean up temporary file on failure
  fi
done
