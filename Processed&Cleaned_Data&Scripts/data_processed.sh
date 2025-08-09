#!/bin/sh
# Reads: emails_cleaned.tsv
# Writes: emails_categorized.tsv (adds a new 'Category' column)

# Corrected input file to match the output of the previous script
INPUT="emails_cleaned.tsv"
OUTPUT="emails_categorized.tsv"

if [ ! -f "$INPUT" ]; then
    echo "ERROR: $INPUT not found. Run data_clean1.sh first."
    exit 1
fi

# AWK script to categorize emails based on sender and labels
awk -F'\t' 'BEGIN {
    OFS="\t";
    # Print the correct header for the output file
    print "FromName", "FromEmail", "ToEmail", "Date", "Subject", "Labels", "Category";
}
NR > 1 {
    # Get all relevant fields in lowercase for case-insensitive matching
    from_name = tolower($1);
    from_email = tolower($2);
    subject = tolower($5);
    labels = tolower($6); # Corrected: Labels are in column 6

    # --- Categorization Logic ---
    category = "Useful"; # Set a default category

    # 1. Check for specific, high-priority categories based on sender email
    if (from_email ~ /linkedin\.com|indeed\.com|naukri\.com|job/) {
        category = "Job Alerts";
    } else if (from_email ~ /@bank|kotak|swiggy|zomato|amazon|flipkart|order|payment|invoice|statement|transaction/) {
        category = "Transactional/Finance";
    }
    # 2. If not matched above, check the email labels
    else if (labels ~ /spam/) {
        category = "Spam";
    } else if (labels ~ /promotions|marketing|offers|sale|promo/) {
        category = "Promotions";
    } else if (labels ~ /social|facebook|twitter|instagram/) {
        category = "Social";
    } else if (labels ~ /updates|notification|alert|google/) {
        category = "Updates";
    }
    
    # Print the original 6 columns plus the new category
    print $1, $2, $3, $4, $5, $6, category;

}' "$INPUT" > "$OUTPUT"

# --- Reporting ---
count=$(wc -l < "$OUTPUT")
count=$((count - 1))
printf "Wrote -> %s (categorized records: %s)\n" "$OUTPUT" "$count"
