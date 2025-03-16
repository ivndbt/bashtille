```
    __               __    __  _ ____   
   / /_  ____ ______/ /_  / /_(_) / /__
  / __ \/ __ `/ ___/ __ \/ __/ / / / _ \
 / /_/ / /_/ (__  ) / / / /_/ / / /  __/
/_.___/\__,_/____/_/ /_/\__/_/_/_/\___/
static site generator
```

# bashtille

A minimal static site generator written in Bash.

With `bashtille` you can:

- Generate or edit all HTML pages in one go
- Generate a sitemap structure
- Generate (and control) an RSS feed

## Installation

Go to your website root directory and run:

```bash
curl -LO https://github.com/ivndbt/bashtille/archive/refs/heads/master.zip
unzip master.zip
cp -r bashtille-master/src/ src/
rm -rf master.zip bashtille-master/
chmod +x /src/bashtille.sh /src/html-compiler.sh /src/sitemap-compiler.sh /src/rss-compiler.sh
```

## Usage

See the [README](/src/README.md) inside the `/src` directory for full documentation.

### Suggested Workflow

`bashtille` is best suited for personal and minimal blogs that share a common header and footer, hosted on static website platforms like GitHub Pages or Cloudflare Pages.

> **Note:** `bashtille` is not designed for complete beginners; it requires some basic knowledge of the terminal and HTML. **You still need to write content using HTML tags.**

### Why Use `bashtille`?

- Helps you understand how websites work under the hood.
- Avoids manually editing all your web pages if you make a change to the header or footer.
- Everything is customizable, giving you full control over your content and design.
- RSS is generated only for posts you want to share publicly.

### Recommended Git Structure

To keep your creative process organized, consider using two branches:

- **`writing` branch** — where you write, generate, and edit content.
- **`master` branch** — where the final, published content is stored (synced with your hosting platform).

#### Example Workflow

```bash
cd ~/website-root-dir
git checkout writing  # Ensure being on the writing branch
# Add new-post.env and optionally include it in the RSS template

# Generate all the files
./src/bashtille html new-post.env
./src/bashtille sitemap
./src/bashtille rss

git add .
git commit -m "Added new post"

git checkout master
git merge writing
# If this isn't the first merge, remove `/src` from the staging area and locally
# If this is the first merge remove it only locally
git rm -r --cached src  # Remove `/src` from Git history
rm -rf src  # Remove `/src` locally
git commit -m "Added new post"

# Publish the new-post online
git push origin master
```

This separation ensures your published branch stays clean, containing only the necessary static files.

