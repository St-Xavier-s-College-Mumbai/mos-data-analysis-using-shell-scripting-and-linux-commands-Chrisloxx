#!/bin/sh

# --- Configuration ---
INPUT_FILE="emails_categorized.tsv"
SPIKE_MULTIPLIER=1.1
MINIMUM_THRESHOLD=3
EMAIL_COUNT_THRESHOLD=5

# --- Script Body ---
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found at '$INPUT_FILE'" >&2
    exit 1
fi

awk -F'\t' 'NR>1 {
    category = $7       # Category column
    date = substr($4, 1, 10) # First 10 chars of Date column (YYYY-MM-DD)
    key = category "\t" date
    counts[key]++
}
END {
    # Output format: Category, Date, Count
    for (k in counts) {
        print k "\t" counts[k]
    }
}' "$INPUT_FILE" |
sort -k1,1 -k2,2 | \
awk -F'\t' -v multiplier="$SPIKE_MULTIPLIER" \
           -v min_threshold="$MINIMUM_THRESHOLD" \
           -v count_threshold="$EMAIL_COUNT_THRESHOLD" \
'BEGIN {
    OFS="\t"
    print "Category","Date","PrevCount","TodayCount","Type"
}
{
    category=$1
    date=$2
    count=$3
    type=""
    
    # More than N emails condition
    if (count > count_threshold) {
        type = (type=="" ? "" : type ",") "HighVolume"
    }
    
    # Spike condition
    if (category==prev_category && prev_count >= min_threshold && count > (prev_count * multiplier)) {
        type = (type=="" ? "" : type ",") "Spike"
    }

    if (type != "") {
        print category, date, prev_count, count, type
    }

    prev_category=category
    prev_count=count
}'

