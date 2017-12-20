# Blip - A Swift/Markdown static blog generator

## Prerequisites

Blip uses a specific directory structure for templates and site organisation. See the [`example-site/`](/example-site) directory for a demo, or read on for a full description.

### Templates

Templates are layout guides for your sites index and posts pages. The following are located in `config/templates/`:

* `index_template.html`: Your site's main index pages.

* `index_post_template.html`: The layout of the post preview on the index pages.

* `post_template.html`: The layout of the individual post page.

### Special Tokens

Blip uses some custom "tokens" for common tasks and text replacements. Use `Config.swift` to customise the replacement strings.

Markdown (Posts):

* `[[MORE]]`: Breaks the post at this point in the `index*.html` pages and inserts a `Read More` link to the full post.

Templates:

* `$(COPYRIGHT)`: Inserts a custom copyright string into an index template.

* `$(POSTS)`: Inserts a list of post snippets into an index template.

* `$(POSTS_OLDER)`: Inserts an "Older Posts" link into an index template.

* `$(POSTS_NEWER)`: Inserts a "Newer Posts" link into an index template.

* `$(POST_TITLE)`: Inserts the post title into a post or index template.

* `$(POST_TIMESTAMP)`: Inserts the post timestamp into a post or index template.

* `$(POST_BODY)`: Inserts the post body into a post or index template (the index template will display up to any `[[MORE]]` token).

* `$(POST_PERMALINK)`: Inserts a post permalink into a post or index template.


### Posts

#### Filenames

Posts should be in [Markdown](https://daringfireball.net/projects/markdown/) format, and should follow a `YYYYMMDD.md` naming convention (the `.markdown` file extension is also supported).

#### Directory Structure

The `posts/` directory should contain at least two sub-directories:

* `drafts`: This is where you should place your Markdown (.md) files for publishing.

* `published`: Blip will generate HTML `index*.html` and post pages in this directory. You should use the contents of this directory for your website.

Published posts are organised according to the date in their filename. So for example, a post with filename `20171220.md` will be published at the following path: `posts/published/2017/12/20.md`. Currently, Blip only supports a single post per day, mainly because I don't blog very often...

### Stylesheets & Images

* `published/stylesheets/`: The default templates use the included `index.css` as a stylesheet. You can drop other CSS files in here and reference in your templates, if required,

* `published/images/`: Drop your images in here, and you can reference them in Markdown as follows: `![image](/images/someimage.jpg)`

## Usage

Write your post in Markdown, with the correct filename convention (`YYYYMMDD.md`), then drop it into the `drafts/` directory.

Then run the following command:

    ./blip /path/to/your/blog/ -r

## Arguments

`-r` Rebuilds the entire site, by publishing all Markdown files in the `drafts/` directory.

`-w` Watches your `drafts/` directory for new Markdown files and automatically publishes them.

`-i` Only rebuild the site `index*.html` pages.

`-h` Displays help.

## Dependencies

* [SwiftFSWatcher](https://github.com/gurinderhans/SwiftFSWatcher)

> A simple easy to use / extend File System watcher using Swift.


* [Down](https://github.com/iwasrobbed/Down)

> Blazing fast Markdown rendering in Swift, built upon cmark.

## Live Example

Visit [my personal site](https://www.vinnycoyne.com) for an example of Blip in use.