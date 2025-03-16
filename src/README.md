# Project Documentation

## Table of Contents
1. [Bashtille - Script Launcher](#bashtille---script-launcher)
2. [HTML Page Compiler](#html-page-compiler)
3. [Sitemap Compiler](#sitemap-compiler)
4. [RSS Feed Compiler](#rss-feed-compiler)

---

# Bashtille - Script Launcher

## Overview
`Bashtille` is a script launcher designed to simplify the use of three individual scripts:

- `html-compiler.sh`
- `sitemap-compiler.sh`
- `rss-compiler.sh`

Instead of running each script manually, `bashtille.sh` allows you to:
- Use quick commands directly from the terminal.
- Access an interactive menu to select the desired script.

## Directory Structure
```
website-root/
│── src/
│   │── bashtille.sh
│   │── html-compiler.sh
│   │── sitemap-compiler.sh
│   │── rss-compiler.sh
```

## Usage
### Quick Command Mode
To run a script directly with arguments:
```bash
./bashtille.sh [OPTION] <arguments>
```

**Options available:**
- `html <file-name.env>` or `html *` — Run the HTML Compiler.
- `sitemap` — Run the Sitemap Compiler.
- `rss` — Run the RSS Compiler.

**Examples:**
```bash
./bashtille.sh html page1.env   # Compiles page1.env
./bashtille.sh html *           # Compiles all .env files in "pages/"
./bashtille.sh sitemap          # Generates sitemap.xml
./bashtille.sh rss              # Generates rss.xml
```

### Interactive Mode
If no arguments are provided, `bashtille.sh` prompts you to select a script interactively:
```bash
./bashtille.sh
```
The following menu will appear:
```
Select a script:
1. HTML Page Compiler
2. Sitemap Compiler
3. RSS Feed Compiler
4. Exit
```
You can then select the desired option by typing the corresponding number.
The interactive menu provides additional prompts for input where required.

> **Warning:**  Running any of these scripts will overwrite existing files with the same path/name.

---

# HTML Page Compiler

## Overview
This script (`html-compiler.sh`) generates HTML files by combining a template (`template-html.html`) with page-specific environment files (`.env`). The script reads variable definitions from `.env` files, replaces placeholders in the template, and outputs the final HTML pages.

## Directory Structure
```
website-root/
│── src/
│   │── html-compiler.sh
│   │── templates/
│   │   └── template-html.html
│   │── pages/
│   │   ├── page1.env
│   │   ├── page2.env
│   │   └── ...
│── temp/
```
- **`src/`**: Contains the script and source files.
- **`templates/`**: Stores the HTML template with placeholders.
- **`pages/`**: Contains `.env` files with variables for each page.
- **`temp/`**: Stores the generated `.html` files if `OUTPUT_DIR` variable is empty or not specified.

## Usage
Run the script from the `src/` directory:

Compile all pages:
```bash
./html-compiler.sh *
```

Compile a specific page (without adding the `pages/` path):
```bash
./html-compiler.sh page1.env
```

The script will look for the `.env` file inside the `pages/` directory automatically. You do not need to specify the full path.


> **Warning:** Running the script will overwrite existing HTML files with the same names in the output directory.

## Writing `.env` Files

Each `.env` file defines variables used in the template. Format:

```env
PAGE_TITLE=My Page Title
PAGE_DESCRIPTION=This is a description & details
MULTILINE_CONTENT='This is a
multiline
content.'
```

### Handling Special Characters
Some characters require escaping to prevent incorrect substitutions:

- ~~**Ampersand (`&`)** must be escaped with a backslash (`\&`) to be treated as text.~~ Fixed
- **Single quotes (`'`)** in multiline values must always be followed by a character. An empty line after a single quote will be considered the end of the variable. To prevent this add a space after `'` if it's the last caracter of the row.
- **Dollar sign (`$`)** followed by a variable name (`$VAR`) is replaced with its value.

## Template Customization

The provided `template-html.html` is already optimized for SEO. However, it is essential to modify it to reflect your project's specific needs. Be sure to adjust:

- **Domain names** to match your site's URL.
- **Favicon paths** for correct asset linking.
- **CSS paths** to ensure proper styling.
- **Usernames** or common descriptions that apply across multiple pages.

These changes ensure consistency and improve the site's overall structure and search engine performance.

## Output
Generated `.html` files are saved in the directory specified by the `OUTPUT_DIR` variable within each `.env` file. If `OUTPUT_DIR` is not set, the default directory is `temp/`.

- If `OUTPUT_DIR` is explicitly set to `/`, the files are saved at the root of the project.
- If `OUTPUT_DIR` is set to a subdirectory like `/notes` or `/notes/`, the files will be saved in that subdirectory.
- If `OUTPUT_DIR` is empty or not specified, the files will be saved in `/temp`.

Example:
```
pages/page1.env  →  temp/page1.html
pages/page2.env  →  $OUTPUT_DIR/page2.html
```

Each output file contains the processed template with the variables replaced by their corresponding values.

---

# Sitemap Compiler

## Overview
This script (`sitemap_compiler.sh`) creates an XML sitemap by scanning `.env` files in the `pages/` directory. It extracts relevant metadata and assigns priority levels based on URL depth.

## Directory Structure
```
website-root/
│── src/
│   │── sitemap_compiler.sh
│   │── pages/
│   │   ├── page1.env
│   │   ├── page2.env
│   │   └── ...
│── sitemap.xml
```
- **`src/`**: Contains the script.
- **`pages/`**: Holds `.env` files with metadata.
- **`sitemap.xml`**: The generated sitemap output file.

## Usage
Run the script from the `src/` directory:
```bash
./sitemap_compiler.sh
```

The script will:
1. Scan all `.env` files in `pages/` (excluding `404.env`).
2. Extract `PAGE_URL` and `LAST_MOD` variables.
3. Assign priority based on URL depth.
4. Sort and generate `sitemap.xml`.

## Output
The `sitemap.xml` file will contain entries in the format:
```xml
<url>
  <loc>https://example.com/page</loc>
  <lastmod>2025-01-01T00:00:00+00:00</lastmod>
  <priority>0.80</priority>
</url>
```

### Priority Calculation
The script determines priority based on the number of slashes (`/`) in the URL:
- Root pages (`https://yourdomain.com/`): **1.00**
- Pages with 3 slashes: **0.80**
- Pages with 4 slashes: **0.64**
- Pages with 5 slashes: **0.51**
- Pages with 6 slashes: **0.41**
- Pages with 7 slashes: **0.33**
- Pages with 8 slashes: **0.26**
- Pages with 9+ slashes: **0.21**

> **Note:** Running the script will overwrite the existing `sitemap.xml` file.

___

# RSS Feed Compiler

## Overview
This script (`rss-compiler.sh`) generates an RSS feed by combining a template file (`template-rss.xml`) with metadata defined in separate `.env` files. Each `.env` file represents a blog post entry and contains information such as title, link, publication date, and description.

## Directory Structure
```
website-root/
│── src/
│   │── rss-compiler.sh
│   │── templates/
│   │   └── template-rss.xml
│   │── pages/
│   │   ├── post1.env
│   │   ├── post2.env
│   │   └── ...
│── rss.xml
```
- **`src/`**: Contains the RSS compiler script and the template.
- **`templates/`**: Stores the RSS template with placeholders.
- **`pages/`**: Contains `.env` files for each RSS entry (e.g., blog posts).
- **`rss.xml`**: The generated RSS feed file.

## Usage
Run the script from the `src/` directory:
```bash
./rss-compiler.sh
```
The script will:
1. Read the `template-rss.xml` file to structure the RSS feed.
2. Identify markers like `!!!post1.env` in the template to include data from corresponding `.env` files in `pages/`.
3. Populate the template with data extracted from these `.env` files.

## Template Customization

The generated RSS feed depends on how `template-rss.xml` is prepared. It is necessary to decide which pages to process to avoid excessively long feeds. Additionally, you can decide which tags to include for each <item> entry. For example, a thumbnail image tag may be omitted for blog posts but included for project entries.

This flexibility allows better control over the content structure and ensures the feed remains concise yet informative.

## Output
The generated `rss.xml` file will contain entries for each `.env` file that is successfully processed. Example:
```xml
<item>
  <title>My Blog Post</title>
  <link>https://yourdomain.com/my-blog-post</link>
  <description>This is a post description.</description>
  <pubDate>Wed, 01 Jan 2025 00:00:00 +0000</pubDate>
</item>
```

> **Note:** Running the script will overwrite the existing `rss.xml` file. Any `.env` files referenced in the template but missing in the `pages/` folder will generate a warning message.

