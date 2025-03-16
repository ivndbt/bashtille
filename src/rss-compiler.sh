#!/bin/bash

# RSS Feed Compiler Script
# --------------------------
# This script generates an RSS feed by merging a template RSS XML file with
# variables defined in separate .env files. The script processes all the
# .env files referenced in the template using the pattern `!!!filename.env`
# and inserts the corresponding content between `<item>` tags.
#
# Usage:
#   ./rss-compiler.sh      # Generates the RSS feed based on the template and .env files.
#
# WARNING: Running this script will overwrite the output file `rss.xml`.

# Set directory paths
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
MAIN_DIR="$(dirname "$SCRIPT_DIR")"
PAGES_DIR="$SCRIPT_DIR/pages"
TEMPLATE_FILE="$SCRIPT_DIR/templates/template-rss.xml"
OUTPUT_FILE="$MAIN_DIR/rss.xml"

# Check if any arguments are passed and report that they are not needed.
if [ $# -gt 0 ]; then
    echo "Usage: No arguments are needed to generate RSS."
    echo "Ignoring argument: $1" # Improved clarity in the error message.
fi

# Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Template file '$TEMPLATE_FILE' not found."
    exit 1
fi

# Function to parse .env files and generate RSS items
parse_env_file() {
    local ENV_FILE="$1"
    declare -A VARS
    VAR_NAME=""
    VAR_VALUE=""
    IS_MULTILINE=0

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ $IS_MULTILINE -eq 0 && $line =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*) ]]; then
            VAR_NAME="${BASH_REMATCH[1]}"
            VAR_VALUE="${BASH_REMATCH[2]}"

            if [[ $VAR_VALUE =~ ^\'(.*) ]]; then
                IS_MULTILINE=1
                VAR_VALUE="${BASH_REMATCH[1]}"
            fi

            VAR_VALUE="$(echo "$VAR_VALUE" | sed 's/&/\\&/g')"  # Escape the "&" character
            VARS["$VAR_NAME"]="$VAR_VALUE"
        elif [[ $IS_MULTILINE -eq 1 ]]; then
            VARS["$VAR_NAME"]+=$'\n'"$line"

            if [[ $line =~ (.*)\'$ ]]; then
                VARS["$VAR_NAME"]="${VARS[$VAR_NAME]::-1}"
                VAR_VALUE="$(echo "${VARS[$VAR_NAME]}" | sed 's/&/\\&/g')"  # Escape the "&" character in multiline
                VARS["$VAR_NAME"]="$VAR_VALUE"  # Needed to escape the "&" character in multiline
                IS_MULTILINE=0
            fi
        fi
    done < "$ENV_FILE"

    # Format date from ISO 8601 to RFC 2822
    VARS["LAST_MOD"]=$(date -u -d "${VARS[LAST_MOD]}" -R 2>/dev/null || echo "${VARS[LAST_MOD]}")

    # Sostituzione delle variabili
    while IFS= read -r line || [ -n "$line" ]; do
        for key in "${!VARS[@]}"; do
            line="${line//\$$key/${VARS[$key]}}"
        done
        echo "$line"
    done
}

# Generazione del file RSS
{
    INSIDE_ITEM=0
    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" =~ ^!!!(.+)\.env ]]; then
            ENV_FILE="$PAGES_DIR/${BASH_REMATCH[1]}.env"
            if [ -f "$ENV_FILE" ]; then
                INSIDE_ITEM=1
            else
                echo "Warning: '$ENV_FILE' not found, skipping..."
            fi
        elif [[ $INSIDE_ITEM -eq 1 ]]; then
            if [[ "$line" =~ ^\<\/item\> ]]; then
                echo "$line"
                INSIDE_ITEM=0
            else
                parse_env_file "$ENV_FILE" <<< "$line"
            fi
        else
            echo "$line"
        fi
    done < "$TEMPLATE_FILE"
} > "$OUTPUT_FILE"

echo "RSS feed generated successfully: $OUTPUT_FILE"
