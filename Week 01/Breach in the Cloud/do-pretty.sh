#!/bin/bash

for file in *.json; do jq . "$file" > "$file.tmp" && mv "$file.tmp" "$file"; done
