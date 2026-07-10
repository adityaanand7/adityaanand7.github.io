#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <grading-worksheet.csv> <log_directory> <moodle_output_directory>"
    echo
    echo "Example:"
    echo "  $0 sample.csv logs/ out/"
    exit 1
fi

CSV_FILE="$1"
LOG_DIR="$2"
SUBMISSIONS_DIR="$3"

declare -A roll_to_name

# Read Moodle grading worksheet
# Columns:
# Identifier,Full name,ID number,...
while IFS=',' read -r identifier fullname roll rest; do
    # Skip header
    [[ "$identifier" == "Identifier" ]] && continue

    # Remove leading/trailing whitespace
    fullname=$(echo "$fullname" | xargs)
    roll=$(echo "$roll" | xargs)

    roll_to_name["$roll"]="$fullname"
done < "$CSV_FILE"

echo "Loaded ${#roll_to_name[@]} students."

shopt -s nullglob

for log_file in "$LOG_DIR"/*.log; do
    roll=$(basename "$log_file" .log)

    name="${roll_to_name[$roll]:-}"

    if [[ -z "$name" ]]; then
        echo "[WARNING] Roll number '$roll' not found in CSV."
        continue
    fi

    target_dir=$(find "$SUBMISSIONS_DIR" -maxdepth 1 -type d -iname "${name}*" | head -n 1)

    if [[ -n "$target_dir" ]]; then
        cp "$log_file" "$target_dir/"
        echo "[OK] $roll -> $(basename "$target_dir")"
    else
        echo "[WARNING] No Moodle folder found for '$name'"
    fi
done

echo "Done."
