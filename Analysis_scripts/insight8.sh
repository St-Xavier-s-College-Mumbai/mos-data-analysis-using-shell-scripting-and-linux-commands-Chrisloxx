#!/bin/sh


# --- Configuration ---
INPUT_FILE="emails_categorized.tsv"

# --- Script Body ---

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file not found at '$INPUT_FILE'"
    exit 1
fi

# This script has three stages:
# 1. AWK: Count all keywords in all categories.
# 2. AWK: Calculate a "Spam Score" for each keyword.
# 3. SORT/HEAD: Rank the keywords and show the top results.

# STAGE 1: Count all keywords per category
awk -F'\t' '
    BEGIN {
        OFS="\t";
        stop_words_str = "a an and are as at be by for from has he in is it its of on that the to was were will with re fwd fw";
        split(stop_words_str, stop_words_arr, " ");
        for (i in stop_words_arr) {
            stop_words[stop_words_arr[i]] = 1;
        }
    }
    NR > 1 {
        category = $7;
        subject = tolower($5);
        gsub(/[[:punct:]]/, "", subject);
        word_count = split(subject, words, " ");
        for (i=1; i <= word_count; i++) {
            word = words[i];
            if (!(word in stop_words) && length(word) > 3) {
                counts[category, word]++;
            }
        }
    }
    END {
        for (key in counts) {
            split(key, parts, SUBSEP);
            print parts[1], parts[2], counts[key];
        }
    }' "$INPUT_FILE" | \

# STAGE 2: Calculate a "Spam Score" for each keyword
awk -F'\t' '
    {
        category = $1
        word = $2
        count = $3
        word_counts[word, category] += count;
    }
    END {
        OFS="\t";
        print "Keyword", "Spam_Count", "Useful_Count", "Spam_Score";

        for (key in word_counts) {
            split(key, parts, SUBSEP);
            word = parts[1];

            if (processed[word] == 1) continue;

            # In POSIX awk, accessing a non-existent key returns 0 in a numeric context.
            spam_count = word_counts[word, "Spam"];
            useful_count = word_counts[word, "Useful"];

            if (spam_count > 0) {
                # Ignore very rare words to reduce noise
                if ((spam_count + useful_count) < 3) continue;

                # Score is the simple ratio of spam vs useful occurrences
                score = spam_count / (useful_count + 1);

                if (score > 1) {
                    print word, spam_count, useful_count, score;
                }
            }
            processed[word] = 1;
        }
    }' | \

# STAGE 3: Rank the results and show the top 20
sort  -k4,4nr | head -n 20
