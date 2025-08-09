#!/bin/sh

# --- Configuration ---
INPUT_FILE="emails_categorized.tsv"
OUTPUT_FILE="output_of_insight10.tsv"

# --- Keyword list (can customize) ---
# Use "|" to separate words. These are case-insensitive.
POSITIVE_WORDS="happy|great|excellent|congratulations|good|thanks|awesome|love|amazing|excited|success|successful|win|won|winner|free|bonus"
NEGATIVE_WORDS="problem|issue|error|fail|failed|urgent|warning|alert|missed|sorry|crash|spam|scam|fraud|complaint|sad|bad|terrible|action required"


# --- Script Body ---
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found at '$INPUT_FILE'"
    exit 1
fi

# 1. Create the new output file and add the header
# Takes the header from the input file and adds a "Sentiment" column.
head -n 1 "$INPUT_FILE" | awk -F'\t' '{print $0 "\tSentiment"}' > "$OUTPUT_FILE"


# 2. Process the data rows line by line
# `tail` skips the header, `while read` processes each email.
tail -n +2 "$INPUT_FILE" | while IFS='	' read -r from_name from_email to_email date subject labels category; do
    
    # Count positive and negative keyword matches in the subject (case-insensitive).
    positive_count=$(echo "$subject" | grep -E -i -o "($POSITIVE_WORDS)" | wc -l)
    negative_count=$(echo "$subject" | grep -E -i -o "($NEGATIVE_WORDS)" | wc -l)

    # Assign a sentiment based on which count is greater.
    sentiment="Neutral"
    if [ "$positive_count" -gt "$negative_count" ]; then
        sentiment="Positive"
    elif [ "$negative_count" -gt "$positive_count" ]; then
        sentiment="Negative"
    fi

    # Append the original line plus the new sentiment column to the output file.
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
        "$from_name" "$from_email" "$to_email" "$date" "$subject" "$labels" "$category" "$sentiment"
    
done >> "$OUTPUT_FILE"

echo "Simple sentiment check complete."
echo "Output saved to: $OUTPUT_FILE"
