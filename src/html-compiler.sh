#!/bin/bash

# HTML Page Compiler Script
# --------------------------
# This script generates HTML pages by merging a template HTML file with
# variables defined in separate .env files. The script processes all the
# .env files in the "pages" directory and creates the corresponding HTML files
# in the specified output directory (defined in each .env file) or defaults to "temp".
#
# Usage:
#   ./html-compiler.sh *               # Compile all pages by processing all .env files in the "pages" directory
#   ./html-compiler.sh page_name.env   # Compile only the specified page (page_name.env)
#
# WARNING: Running this script will overwrite output files with the same name.

# Check if no arguments are passed
if [ $# -lt 1 ]; then
    echo "Usage: $0 <file-name.env> or $0 * to process all .env files"
    exit 1
fi

# Set directory paths
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
MAIN_DIR="$(dirname "$SCRIPT_DIR")"
PAGES_DIR="$SCRIPT_DIR/pages"
TEMPLATE_DIR="$SCRIPT_DIR/templates"
DEFAULT_OUTPUT_DIR="$MAIN_DIR/temp"  # Default output directory if not specified in .env

# Ensure the default output directory exists
mkdir -p "$DEFAULT_OUTPUT_DIR"

# Verify the existence of the template file
TEMPLATE_FILE="$TEMPLATE_DIR/template-html.html"
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: The template file '$TEMPLATE_FILE' does not exist."
    exit 1
fi

# Function to generate an HTML file from an .env file
generate_html() {
    local ENV_FILE="$1"
    local BASENAME="${ENV_FILE%.env}"
    declare -A VARS
    VAR_NAME=""
    VAR_VALUE=""
    IS_MULTILINE=0  # If the value is multiline use appropriate function

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

    # Determine output directory (default to /temp if not set)
    OUTPUT_DIR="${VARS[OUTPUT_DIR]:-/temp}"
    if [[ "$OUTPUT_DIR" == "/" ]]; then
    	OUTPUT_DIR=""  # Root directory should not have extra slashes
	else
    	OUTPUT_DIR="${OUTPUT_DIR#/}"  # Remove leading slash if present
    	OUTPUT_DIR="${OUTPUT_DIR%/}"  # Remove trailing slash if present
	fi
    OUTPUT_PATH="$MAIN_DIR/$OUTPUT_DIR"
    mkdir -p "$OUTPUT_PATH"

    # Generate the output file path, ensuring no double slashes
	if [[ -z "$OUTPUT_DIR" ]]; then
    	OUTPUT_FILE="$MAIN_DIR/$(basename "$BASENAME").html"  # if OUTPUT_DIR is empty path is root
	else
    	OUTPUT_FILE="$OUTPUT_PATH/$(basename "$BASENAME").html"
	fi
    
    # Read the template file
    OUTPUT=$(cat "$TEMPLATE_FILE")
    
    # Replace the variables in the template
    for KEY in "${!VARS[@]}"; do
        OUTPUT="${OUTPUT//\$$KEY/${VARS[$KEY]}}"
    done

    # Write the generated HTML to the output file
    echo "$OUTPUT" > "$OUTPUT_FILE"
    echo "File '$OUTPUT_FILE' generated successfully."
}

# If the first argument is *, it means multiple files need to be processed
if [ "$1" == "*" ] || [ $# -gt 1 ]; then
    ENV_FILES=("$PAGES_DIR"/*.env)

    # If * expansion finds no files, ENV_FILES will contain the literal "*.env"
    if [ "${ENV_FILES[0]}" == "$PAGES_DIR/*.env" ]; then
        echo "Error: No .env files found in '$PAGES_DIR'."
        exit 1
    fi

    # Process each .env file
    for FILE in "${ENV_FILES[@]}"; do
        generate_html "$FILE"
    done
else
    ENV_FILE="$PAGES_DIR/$1"
    if [ ! -f "$ENV_FILE" ]; then
        echo "Error: The file '$ENV_FILE' does not exist in '$PAGES_DIR'."
        exit 1
    fi
    generate_html "$ENV_FILE"
fi

