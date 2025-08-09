#!/bin/sh

# --- Configuration ---
INPUT_FILE="emails_categorized.tsv"

# --- Script Body ---

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found at '$INPUT_FILE'"
    exit 1
fi

# Print the final report header.
printf "Category\tKeyword\tCount\n"

# STAGE 1: AWK - Extract and count keywords
awk -F'\t' '
    BEGIN {
        OFS = "\t"
        stop_words_str = "a an and are as at be by for from has he in is it its of on that the to was were will with re fwd fw you your"
        split(stop_words_str, stop_words_arr, " ")
        for (i in stop_words_arr) {
            stop_words[stop_words_arr[i]] = 1
        }
    }
    NR > 1 {
        category = $7
        subject = tolower($5)       # Assign subject before gsub
        gsub(/[[:punct:]]/, "", subject)
        word_count = split(subject, words, " ")
        for (i = 1; i <= word_count; i++) {
            word = words[i]
            if (!(word in stop_words) && length(word) > 2) {
                counts[category, word]++
            }
        }
    }
    END {
        for (key in counts) {
            split(key, parts, SUBSEP)
            print parts[1], parts[2], counts[key]
        }
    }
' "$INPUT_FILE" | \

# STAGE 2: SORT - rank keywords within each category
sort -t'	' -k1,1 -k3,3nr | \

# STAGE 3: AWK - print top 5 keywords per category 
awk -F'\t' '
    $1 != prev_cat {
        prev_cat = $1
        n = 0
    }
    {
        n = n + 1
        if (n <= 5) {
            print $0
        }
    }
'

