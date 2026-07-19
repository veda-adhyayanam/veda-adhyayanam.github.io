#!/bin/bash
# Run from the root of your git repo (veda-adhyayanam.github.io)

PDF_DIR="PDFs"
OUTPUT="pdf-dates.json"

echo "{" > "$OUTPUT"

first=true
# Use find to handle filenames with spaces/Telugu characters safely
find "$PDF_DIR" -type f -name "*.pdf" -print0 | sort -z | while IFS= read -r -d '' file; do
    # Get the last commit date that touched this file, format DD-MON-YYYY
    last_date=$(git log -1 --format="%ad" --date=format:"%d-%b-%Y" -- "$file")

    # If the file isn't committed yet, fall back to "Not committed"
    if [ -z "$last_date" ]; then
        last_date="Not committed"
    fi

    # Escape backslashes/quotes in filename for JSON safety, keep UTF-8 (Telugu) as-is
    key=$(printf '%s' "$file" | sed 's/\\/\\\\/g; s/"/\\"/g')

    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$OUTPUT"
    fi
    printf '  "%s": "%s"' "$key" "$last_date" >> "$OUTPUT"
done >> "$OUTPUT"

echo "" >> "$OUTPUT"
echo "}" >> "$OUTPUT"

echo "✅ Wrote $OUTPUT"