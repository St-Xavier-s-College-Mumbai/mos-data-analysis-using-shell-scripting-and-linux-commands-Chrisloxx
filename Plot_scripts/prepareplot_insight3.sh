#!/bin/sh

# This script pivots the month-wise trend data from a "long" format
# to a "wide" format, which is easier for gnuplot to plot.

# --- Configuration ---
INPUT_FILE="output_of_insight3.tsv"
OUTPUT_FILE="plot_output_of_insight3.tsv"

# --- Script Body ---
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found at '$INPUT_FILE'"
    exit 1
fi

# This awk script collects all data, then prints it in a pivoted table.
# Note: This uses gawk-specific features like asorti for simplicity,
# which is standard on your Pop!_OS system.
awk -F'\t' '
    NR > 1 {
        # Collect all unique months and categories
        months[$2] = 1
        categories[$1] = 1
        # Store the data in a 2D array: data[month, category] = count
        data[$2, $1] = $3
    }
    END {
        # First, sort the categories alphabetically for a consistent header
        n = asorti(categories, sorted_categories)
        
        # Print the header row (e.g., Month  Job Alerts  Promotions ...)
        printf "Month"
        for (i=1; i<=n; i++) {
            printf "\t%s", sorted_categories[i]
        }
        printf "\n"

        # Now, sort the months chronologically to print the data
        m = asorti(months, sorted_months)
        for (i=1; i<=m; i++) {
            month = sorted_months[i]
            printf "%s", month
            for (j=1; j<=n; j++) {
                category = sorted_categories[j]
                # Print the count, or 0 if no emails for that month/category
                count = data[month, category] ? data[month, category] : 0
                printf "\t%s", count
            }
            printf "\n"
        }
    }
' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Pivoted data for plotting has been saved to: $OUTPUT_FILE"
