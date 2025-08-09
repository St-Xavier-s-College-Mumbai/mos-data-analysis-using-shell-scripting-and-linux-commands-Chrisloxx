#!/bin/sh

# --- Configuration ---
INPUT_FILE="emails_categorized.tsv"

# --- Script Body ---

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found at '$INPUT_FILE'"
    exit 1
fi

awk -F'\t' '
    NR > 1 {
        counts[$1, $7]++;
    }
    END {
        OFS="\t";
        for (key in counts) {
            split(key, parts, SUBSEP);
            print parts[1], parts[2], counts[key];
        }
    }' "$INPUT_FILE" | \
sort -t'	' -k2,2 -k3,3nr | \
(
    # Print the header line first.
    printf "Sender\tCategory\tCount\n";

    # This loop reads the sorted data line by line to find the top 3.
    # Initialize variables to track the category and count.
    prev_category=""
    count=0

    # Set IFS to a literal tab to correctly read the columns.
    while IFS='	' read -r sender category num_count; do
        if [ "$category" != "$prev_category" ]; then
            # If we see a new category, reset the counter.
            count=1
            prev_category="$category"
        else
            # If it's the same category, increment the counter.
            count=$((count + 1))
        fi

        # Only print if the counter is 3 or less.
        if [ "$count" -le 3 ]; then
            printf "%s\t%s\t%s\n" "$sender" "$category" "$num_count"
        fi
    done
)
