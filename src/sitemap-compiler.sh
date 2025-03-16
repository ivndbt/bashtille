#!/bin/bash

# Sitemap Compiler Script
# -------------------------
# This script generates a `sitemap.xml` file by extracting information from `.env` files
# located in the `pages` directory. It reads specific variables (PAGE_URL, LAST_MOD) 
# and assigns priority based on the URL depth.
#
# Usage:
#   ./sitemap-compiler.sh    # Generates a sitemap from all valid .env files
#
# NOTE: The script will exit without generating a sitemap if any `.env` file is missing required variables.
# WARNING: Running this script will overwrite the output file `sitemap.xml`.

# Set directory paths
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
MAIN_DIR="$(dirname "$SCRIPT_DIR")"
PAGES_DIR="$SCRIPT_DIR/pages"
OUTPUT_FILE="$MAIN_DIR/sitemap.xml"

# Check if any arguments are passed and report that they are not needed.
if [ $# -gt 0 ]; then
    echo "Usage: No arguments are needed to generate RSS."
    echo "Ignoring argument: $1" # Improved clarity in the error message.
fi

# Function to process each .env file and extract necessary data
generate_sitemap() {
    local ENV_FILE="$1"
    declare -A VARS
    VAR_NAME=""
    VAR_VALUE=""
    error_occurred=false

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*) ]]; then
            VAR_NAME="${BASH_REMATCH[1]}"
            VAR_VALUE="${BASH_REMATCH[2]}"

            # Read only required variables
            if [[ "$VAR_NAME" == "PAGE_MAIN" || "$VAR_NAME" == "LAST_MOD" || "$VAR_NAME" == "PAGE_URL" ]]; then
                VARS["$VAR_NAME"]="$VAR_VALUE"
            fi
        fi
        # Stop reading variables if PAGE_MAIN is found
        if [[ "$VAR_NAME" == "PAGE_MAIN" ]]; then
            break
        fi
    done < "$ENV_FILE"

    # Ensure required variables are present
    if [ -z "${VARS[PAGE_URL]}" ]; then
        echo "Error: PAGE_URL is missing or empty in $ENV_FILE."
        error_occurred=true
    fi

    if [ -z "${VARS[LAST_MOD]}" ]; then
        echo "Error: LAST_MOD is missing or empty in $ENV_FILE."
        error_occurred=true
    fi

    # Stop if errors are found
    if [ "$error_occurred" = true ]; then
        return 1
    fi

    # Count slashes in PAGE_URL to determine priority
    slash_count=$(awk -F"/" '{print NF-1}' <<< "${VARS[PAGE_URL]}")

    # Assign priority based on slash count
    case $slash_count in
        3) PRIORITY="0.80" ;;
        4) PRIORITY="0.64" ;;
        5) PRIORITY="0.51" ;;
        6) PRIORITY="0.41" ;;
        7) PRIORITY="0.33" ;;
        8) PRIORITY="0.26" ;;
        *) PRIORITY="0.21" ;; # Lowest priority
    esac

    # Append data to temporary file for sorting
    echo "$PRIORITY ${VARS[PAGE_URL]} ${VARS[LAST_MOD]}" >> "$temp_file"
}

# Create temporary file for storing URL data
temp_file=$(mktemp)

# Process all .env files in pages directory, excluding 404.env
for env_file in "$PAGES_DIR"/*.env; do
    [[ "$env_file" == *"404.env" ]] && continue

    generate_sitemap "$env_file"
    
    # Exit if an error was encountered
    if [ $? -ne 0 ]; then
        echo "Sitemap generation aborted."
        rm -f "$temp_file"
        exit 1
        break
    fi
done

# Write XML header for sitemap
cat <<EOF > "$OUTPUT_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<urlset
      xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
            http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">

<!-- Generated with bashtille -->

  <url>
    <loc>https://yourdomain.com/</loc>
    <lastmod>2025-01-01T00:00:00+00:00</lastmod>
    <priority>1.00</priority>
  </url>
EOF

# Sort by PRIORITY (descending) and append to sitemap
if [ -f "$temp_file" ]; then
    sort -k1,1nr "$temp_file" | while read -r priority url lastmod; do
        cat <<EOF >> "$OUTPUT_FILE"
  <url>
    <loc>$url</loc>
    <lastmod>$lastmod</lastmod>
    <priority>$priority</priority>
  </url>
EOF
    done
fi

# Close XML file
echo "</urlset>" >> "$OUTPUT_FILE"
rm -f "$temp_file"

echo "Sitemap generated: $OUTPUT_FILE"
