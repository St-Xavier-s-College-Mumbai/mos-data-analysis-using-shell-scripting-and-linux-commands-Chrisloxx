#!/bin/sh


# --- Configuration ---
INPUT_FILE="emails_categorized.tsv"
OUTPUT_FILE="output_of_insight4.tsv"

# --- Script Body ---
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found at '$INPUT_FILE'"
    exit 1
fi

# This pipeline gets the counts, re-formats them, and saves them.
awk -F'\t' 'NR>1 {print $7}' "$INPUT_FILE" | \
sort | \
uniq -c | \
sort -nr | \
awk '{
    count = $1;
    # Rebuild the category name which might have spaces
    category = "";
    for (i=2; i<=NF; i++) {
        category = category (category=="" ? "" : " ") $i
    }
    # Print in "Category    Count" format
    print category "\t" count;
}' > "$OUTPUT_FILE"

echo "Data for plotting has been saved to: $OUTPUT_FILE"
