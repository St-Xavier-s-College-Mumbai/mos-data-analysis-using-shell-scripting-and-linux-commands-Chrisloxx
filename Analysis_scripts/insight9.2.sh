#!/bin/sh

# --- Configuration ---
INPUT_FILE="emails_categorized.tsv"

# --- Script Body ---
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found at '$INPUT_FILE'"
    exit 1
fi

# Calculate total email count
total=$(awk -F'\t' 'NR>1 {print $4}' "$INPUT_FILE" | wc -l)

echo -e "Day\tEmail_Count\tPercentage"
awk -F'\t' '
    NR>1 {
        date_str = substr($4, 1, 10);
        cmd = "date -d \"" date_str "\" +\"%a\"";
        if ((cmd | getline day_of_week) > 0) {
            print day_of_week;
        }
        close(cmd);
    }
' "$INPUT_FILE" | \
sort | uniq -c | sort -nr | \
awk -v total="$total" '{printf "%s\t%d\t%.2f%%\n", $2, $1, ($1/total)*100}'
sort -k2,2nr   #for desc order
