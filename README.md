# jekyll-versioned_files plugin

This creates a [Jekyll::Collection](https://jekyllrb.com/docs/collections/) directory containing a document for each git revision of each file listed in a `_config.yml versioned_file_options[files]:` custom setting. It also creates sets of [git](https://git-scm.com/docs/git-diff) [diffs](https://en.wikipedia.org/wiki/Diff_utility) between those revisions.

A working example can be found at [http://random.parts/adhd-dyslexia/](http://random.parts/adhd-dyslexia/) and the site repo [github.com/random-parts/random-parts.github.io](https://github.com/random-parts/random-parts.github.io)

## Installation

Add the Gem to the `Gemfile`:

```ruby
# Gemfile

group :jekyll_plugins do
  gem "jekyll-versioned_files"
end
```

Add the Gem to the Jekyll gems setting in `_config.yml`:

```yaml
# _config.yml

gems:
  - jekyll-versioned_files
```

## Configuration

Add the collection setting in the `_config.yml`.
`{ versioned=>true }` must be set to the collection metadata for the designated versioned-files collection.

```yaml
# _config.yml `jekyll-versioned_files` collection defaults

collections:
  collection_labelname:
    output: false
    permalink: /:collection/:path/
    versioned: true
```

`versioned_file_options` Configuration settings have been updated for the addition of the `git diff` feature.

`files` is the only requirement and takes one `sitesource/path/filename.ext` or an array of files.
The rest are defaults that can be changed.

`formatting` sets the output type and ignore options for `git diff` files generated between pairs of file revisions.

- Set the `diff_ignore` options and the `output` style for the created comparison files.
- Read about the `git diff` [ignore options here](https://git-scm.com/docs/git-diff#git-diff---ignore-space-change)
- `diff_limit` will limit the diff pairs that are created to adjacent revisions only.

- `output: html` surrounds a deletion with `<del>` and an addition with `<ins>`.
- `output: markdown` uses `**strong**` for additions and `~~del~~` for deletions.

`frontmatter`

- The files Front Matter `permalink` key is changed to `orig_permalink` (if present) to prevent it from rendering out to that location. Change the name in the `_config`
- The `diff` word change count is added as [Front Matter](https://jekyllrb.com/docs/frontmatter/) keys `diff_del` and `diff_ins`.
- A [Front Matter](https://jekyllrb.com/docs/frontmatter/) key `sha` is added with the file's commit hash for a versioned file, and as an array of the two hashes use for `git diff`.
- A [Front Matter](https://jekyllrb.com/docs/frontmatter/) key `ver` is added with the revision version number or as an array containing the pair `diff` versions.
- If no changes have been made between the pair, a `no_change: true` entry is added.

The created `diff` files insert a new Front Matter block at the top so any changes made to the original Front Matter will show up in the `page.content` [variable](https://jekyllrb.com/docs/variables/#page-variables)

```yaml
#_config.yml `versioned_file_options` DEFAULTS

versioned_file_options:
  files: # file is required
    - foo/bar.md
  formatting:
    diff_ignore:
      ignore-all-space: false
      ignore-blank-lines: true
      ignore-space-change: true
    diff_limit: false
    output: markdown           # or html
  frontmatter:
    permalink: orig_permalink  # alt_name || false
    diff_del: diff_del         # alt_name || false
    diff_ins: diff_ins         # alt_name || false
    sha: sha                   # alt_name || false
    ver: ver                   # alt_name || false
```

## Usage

[Collection](https://jekyllrb.com/docs/collections/) and [Documents](https://jekyllrb.com/docs/collections/#documents) can be accessed using [Jekyll Liquid](https://learn.cloudcannon.com/jekyll-cheat-sheet/) output:

```liquid
{{ site.collection_labelname }}

<!-- Loop through the versioned-files _collection[documents] -->
{% for doc in site.collection_name.docs %}
  {{ doc.relative_path }}: {{ doc.content }}
  <hr>
{% end for %}
```

Versioned files are created at `site.source/_collection_labelname/v#/filename.ext`.

- `path/filename` is flattened in the versioned-files collection to `path_filename.ext`

Compared `diff` files are created at `site.source/_collection_labelname/diffs/v#/v#_v#_filename.ext`

```shell
# created directory & file structure
# site.source/
_collection_labelname/
    diffs/
        v1/
          v1_v2_foo_bar.md
          v1_v2_hello_world.md
          v1_v3_hello_world.md
        v2/
          v2_v3_hello_world.md
    v1/
      foo_bar.md
      hello_world.md
    v2/
      foo_bar.md
      hello_world.md
    v3/
      hello_world.md
  etc
```

### GitHub Pages + jekyll-versioned_files w/ Travis CI

As custom plugins do not work with GitHub Pages alone,
[Travis CI](https://travis-ci.org) w/ [GitHub deployment](https://docs.travis-ci.com/user/deployment/pages/) can be used with the plugin to create the `_collection/directory/` and `_collection/directory/versioned_files.ext` in the GitHub Pages repository - for GitHub Pages to access.

- If using Travis CI to create the files for GitHub Pages, the [collection](https://jekyllrb.com/docs/collections/) must be set in the `_config.yml` so gh-pages adds the collection when it renders the site.

Create a `.travis.yml` and set the `Environment Variable:` `$GITHUB_TOKEN` in Travis CI settings with a [GitHub Access Token](https://github.com/settings/tokens).

```yaml
# basic `.travis.yml` - add to gh-pages repo

language: ruby
rvm:
- 2.5.1
script: "bundle exec jekyll build -V"

deploy:
  provider: pages
  skip-cleanup: true
  github-token: $GITHUB_TOKEN  # Set in travis-ci.org dashboard, marked secure
  keep-history: true
  on:
    branch: master
  target-branch: master # branch to push contents to, defaults to `gh-pages`
```

## License

Copyright © 2018 random-parts

Distributed under the [Apache License 2.0 License](http://www.apache.org/licenses/LICENSE-2.0 ).
