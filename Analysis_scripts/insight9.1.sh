#!/bin/sh

# --- Configuration ---
INPUT_FILE="emails_categorized.tsv"

# --- Script Body ---
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found at '$INPUT_FILE'"
    exit 1
fi

# Calculate total email count
total=$(awk -F'\t' 'NR>1 {print substr($4, 12, 2)}' "$INPUT_FILE" | wc -l)

echo -e "Hour\tEmail_Count\tPercentage"
awk -F'\t' 'NR>1 {print substr($4, 12, 2)}' "$INPUT_FILE" | \
sort | \
uniq -c | \
sort -nr | \
awk -v total="$total" '{printf "%02d\t%d\t%.2f%%\n", $2, $1, ($1/total)*100}' | \
sort -k2,2nr   #for desc order

