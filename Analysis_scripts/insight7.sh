#!/bin/sh

# --- Configuration ---
INPUT_FILE="emails_categorized.tsv"

# --- Script Body ---

# 1. Check if the input file exists.
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found at '$INPUT_FILE'"
    exit 1
fi

# 2. This step finds all "Spam" emails, counts them per month,
#    and formats the final report.
awk -F'\t' '
    # For every row, if the 7th column is exactly "Spam"...
    $7 == "Spam" {
        # ...print the year and month and date (e.g., "2025-07-25").
        print substr($4, 1, 10)
    }
' "$INPUT_FILE" | \
sort | \
uniq -c | \
awk '
    # This final awk script formats the output for readability.
    BEGIN {
        OFS="\t";
        print "Month", "Spam_Count";
    }
    {
        # Input from uniq -c is "  COUNT MONTH".
        # We swap them to print MONTH then COUNT.
        print $2, $1;
    }
'
