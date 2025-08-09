#!/bin/sh
# --- Configuration ---
INPUT_FILE="emails_categorized.tsv"

# --- Script Body ---

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found at '$INPUT_FILE'"
    exit 1
fi

# 2. Process the file using awk to count and sort to organize.
awk -F'\t' '
# Skip the header row.
NR > 1 {
    # Extract the year and month (e.g., "2025-07") from the Date column ($4).
    month = substr($4, 1, 7);
    
    # Get the Category from column $7.
    category = $7;
    
    # Use an array to count each unique combination of category and month.
    counts[category, month]++;
}
END {
    # After processing the whole file, print a header.
    OFS="\t";
    print "Category", "Month", "Count";

    # Loop through all collected counts and print the results.
    for (key in counts) {
        split(key, parts, SUBSEP);
        print parts[1], parts[2], counts[key];
    }
}' "$INPUT_FILE" | sort -t'	' -k1,1 -k2,2

