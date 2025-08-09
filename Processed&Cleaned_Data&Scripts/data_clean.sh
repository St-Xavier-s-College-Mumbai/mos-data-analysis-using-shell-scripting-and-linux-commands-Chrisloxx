#!/bin/sh
export LC_ALL=C.UTF-8

INPUT="ChrisloAllMail.mbox"
TMP="${INPUT}.lf"
OUTPUT="emails_cleaned.tsv"

# 1) Normalize CRLF -> LF
sed 's/\r$//' "$INPUT" > "$TMP"

# 2) TSV header (6 columns)
printf 'FromName\tFromEmail\tToEmail\tDate\tSubject\tLabels\n' > "$OUTPUT"

# 3) Process mbox with the final, corrected awk script
awk '
function trim(s) { gsub(/^[ \t"]+|[ \t"]+$/, "", s); return s; }

function parse_date(raw_date, parts, day, month_name, year, time, i, month_names) {
    if (!month_map_initialized) {
        split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", month_names, " ");
        for (i=1; i<=12; i++) { __month_map[month_names[i]] = sprintf("%02d", i); }
        month_map_initialized = 1;
    }
    if (match(raw_date, /[ \t]*([0-9]{1,2})[ \t]+([A-Za-z]{3})[ \t]+([0-9]{4})[ \t]+([0-9]{2}:[0-9]{2}:[0-9]{2})/ , parts)) {
        day = sprintf("%02d", parts[1]); month_name = parts[2]; year = parts[3]; time = parts[4];
        if (month_name in __month_map) { return year "-" __month_map[month_name] "-" day " " time; }
    } else if (match(raw_date, /([0-9]{4})-([0-9]{2})-([0-9]{2})[ T]([0-9]{2}:[0-9]{2}:[0-9]{2})/, parts)) {
        return parts[1] "-" parts[2] "-" parts[3] " " parts[4];
    }
    return trim(raw_date);
}

function decode_header(header,   cmd, result, c, m) {
    # --- THIS IS THE FIX: A more robust regular expression ---
    if (header ~ /^=\?[^?]+\?[QqBb]\?/) {
        
        # Handle Quoted-Printable strings
        if (header ~ /\?[Qq]\?/) {
            sub(/^=\?.*\?[Qq]\?/, "", header); sub(/\?=$/, "", header); gsub("_", " ", header);
            while (match(header, /=([0-9A-Fa-f]{2})/, m)) {
                c = sprintf("%c", strtonum("0x" m[1]));
                header = substr(header, 1, RSTART-1) c substr(header, RSTART+RLENGTH);
            }
            return header;
        }
        
        # Handle Base64 strings
        else if (header ~ /\?[Bb]\?/) {
            sub(/^=\?.*\?[Bb]\?/, "", header); sub(/\?=$/, "", header);
            gsub(/\\/, "\\\\", header); gsub(/"/, "\\\"", header); gsub(/`/, "\\`", header);
            
            cmd = "printf \"%s\" \"" header "\" | base64 -d";
            if ((cmd | getline result) >= 0) { # Use >= to handle output with no newline
                close(cmd);
                return result;
            }
            close(cmd);
            return header; # Fallback on error
        }
    }
    return header; # Return original if not encoded
}

BEGIN { RS="\nFrom "; ORS=""; month_map_initialized = 0; }

NR > 1 {
    from_raw=""; to_raw=""; date_raw=""; subject_raw=""; labels="";
    n = split($0, L, "\n");
    for (i=1; i<=n; i++) {
        line = L[i];
        if (line ~ /^[[:space:]]*$/) { break; }
        if (line ~ /^[ \t]/) {
            if (field == "From") from_raw = from_raw " " trim(line);
            else if (field == "To") to_raw = to_raw " " trim(line);
            else if (field == "Date") date_raw = date_raw " " trim(line);
            else if (field == "Subject") subject_raw = subject_raw " " trim(line);
            else if (field == "Labels") labels = labels " " trim(line);
        } else {
            if (line ~ /^From:/) { field="From"; from_raw=substr(line, index(line,":")+1); }
            else if (line ~ /^To:/) { field="To"; to_raw=substr(line, index(line,":")+1); }
            else if (line ~ /^Date:/) { field="Date"; date_raw=substr(line, index(line,":")+1); }
            else if (line ~ /^Subject:/) { field="Subject"; subject_raw=substr(line, index(line,":")+1); }
            else if (line ~ /^X-Gmail-Labels:/) { field="Labels"; labels=substr(line, index(line,":")+1); }
            else { field=""; }
        }
    }
    from_name = from_raw; from_email = from_raw;
    if (match(from_raw, /<.*>/)) { from_name = substr(from_raw, 1, RSTART-1); from_email = substr(from_raw, RSTART+1, RLENGTH-2); }
    to_email = to_raw;
    if (match(to_raw, /<.*>/)) { to_email = substr(to_raw, RSTART+1, RLENGTH-2); }
    
    from_name = decode_header(trim(from_name)); 
    subject = decode_header(trim(subject_raw));

    from_email = trim(from_email); to_email = trim(to_email);
    clean_date = parse_date(date_raw);
    gsub(/\r|\t|\n/, " ", labels); gsub(/[ ]+/, " ", labels);
    
    printf("%s\t%s\t%s\t%s\t%s\t%s\n", trim(from_name), trim(from_email), trim(to_email), trim(clean_date), trim(subject), trim(labels)) >> "'"$OUTPUT"'"
}
' "$TMP"

# Clean up temporary file and confirm
rm "$TMP"
count=$(wc -l < "$OUTPUT")
count=$((count - 1))
printf "Wrote -> %s (records: %s)\n" "$OUTPUT" "$count"
