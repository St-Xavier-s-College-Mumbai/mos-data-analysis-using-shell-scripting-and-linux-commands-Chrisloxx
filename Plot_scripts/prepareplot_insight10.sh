#!/bin/sh
# sentiment_count_default.sh
INPUT_FILE="output_of_insight10.tsv"
OUTPUT_FILE="plot_output_of_insight10.tsv"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: $INPUT_FILE not found" >&2
    exit 1
fi

# Count sentiments and output: Sentiment<TAB>Count
awk -F'\t' '
    NR>1 {
        s = $7
        gsub(/^[ \t\r\n]+|[ \t\r\n]+$/, "", s)
        count[s]++
    }
    END {
        for (k in count) {
            printf "%s\t%d\n", k, count[k]
        }
    }
' "$INPUT_FILE" | sort -k2,2nr > "$OUTPUT_FILE"

echo "Saved counts to: $OUTPUT_FILE"

