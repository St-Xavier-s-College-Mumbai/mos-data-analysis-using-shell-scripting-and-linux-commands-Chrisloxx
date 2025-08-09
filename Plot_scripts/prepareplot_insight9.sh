#!/bin/sh

# This script calculates the number of emails received for each hour
# of each day of the week, creating a data file suitable for a heatmap.

# --- Configuration ---
INPUT_FILE="emails_categorized.tsv"
OUTPUT_FILE="plot_output_of_insight9.tsv"

# --- Script Body ---
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found at '$INPUT_FILE'"
    exit 1
fi

# This pipeline calculates the email count and now filters out any
# potential blank lines that would cause gnuplot to fail.
awk -F'\t' '
    NR > 1 {
        date_str = substr($4, 1, 10);
        hour = substr($4, 12, 2);
        cmd = "date -d \"" date_str "\" +\"%u %a\"";
        if ((cmd | getline day_info) > 0) {
            print day_info, hour;
        }
        close(cmd);
    }
' "$INPUT_FILE" | \
sort -k1,1n -k3,3n | \
uniq -c | \
awk '{
    # Input is: COUNT DayNum DayName Hour
    # Output:   Hour DayNum Count
    print $4, $2, $1
}' | \
grep . > "$OUTPUT_FILE" # <-- FIX: This filters out any blank lines.

echo "Data for heatmap has been saved to: $OUTPUT_FILE"
