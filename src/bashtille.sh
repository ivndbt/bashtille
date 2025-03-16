#!/bin/bash

# Bashtille - Multi-Function Compiler Script
# ------------------------------------------
# This script serves as a quick launcher for three different compiler scripts:
# - HTML Page Compiler
# - Sitemap Compiler
# - RSS Feed Compiler
#
# Usage:
#   ./bashtille.sh [OPTION] <arguments>
#
# Options available are:
#   html <file-name.env> or *     # Compile HTML pages using .env files
#   sitemap                       # Generate a sitemap.xml file
#   rss                           # Generate an RSS feed file
#
# If no arguments are provided, an interactive menu will guide you through the options.
#
# WARNING: Running any of these scripts will overwrite existing files with the same path/name.

# Set directory path
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Quick execution with arguments
if [[ $# -gt 0 ]]; then
  case $1 in
    html)
      $SCRIPT_DIR/html-compiler.sh "${@:2}" # Pass all arguments except the first one
      ;;
    sitemap)
      $SCRIPT_DIR/sitemap-compiler.sh "${@:2}"
      ;;
    rss)
      $SCRIPT_DIR/rss-compiler.sh "${@:2}"
      ;;
    *)
      echo "Invalid option: $1"
      echo ""
      echo "Usage:"
      echo "  ./bashtille.sh [OPTION] <arguments>"
      echo ""
      echo "Options available are:"
      echo "  html <file-name.env> or *"
      echo "  sitemap"
      echo "  rss"
      exit 1
      ;;
  esac
  exit 0
fi

# Warning prompt
echo "WARNING: Running any of these scripts will overwrite existing files with the same path/name."

# Interactive menu if no arguments are passed
echo "Select a script:"
echo "1. HTML Page Compiler"
echo "2. Sitemap Compiler"
echo "3. RSS Feed Compiler"
echo "4. Exit"

read -p "Choose [1/2/3/4]: " choice

case $choice in
  1)
    echo "Select a <file-name.env> or * to process all .env files in /pages"
    read -p "Choose: " filename
    echo "Running HTML Page Compiler for $filename file..."
    $SCRIPT_DIR/html-compiler.sh $filename
    ;;
  2)
    echo "Running Sitemap Compiler..."
    $SCRIPT_DIR/sitemap-compiler.sh
    ;;
  3)
    echo "Running RSS Compiler..."
    $SCRIPT_DIR/rss-compiler.sh
    ;;
  4)
    echo "Script terminated."
    exit 0
    ;;
  *)
    echo "Invalid input, script terminated."
    ;;
esac

exit 0