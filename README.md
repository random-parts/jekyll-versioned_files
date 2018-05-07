# jekyll-versioned_files plugin

This creates a [Jekyll::Collection](https://jekyllrb.com/docs/collections/) directory containing a document for each git revision of each file listed in a `_config.yml` custom setting.

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

Add the collection setting in the `_config.yml`.
`{ versioned=>true }` must be set to the collection metadata for the designated versioned-files collection. Otherwise, a default collection will be made.

```yaml
# _config.yml

collections:
  collection_labelname:
    output: false
    versioned: true
```

Set the custom settings for `jekyll-versioned_files` in `_config.yml`.

Add a single file or an array of files. [ `path/filename` from `site.source` ]

```yaml
# _config.yml

# single file
git_versioned_file: hello_world.md

# or an array of files
git_versioned_file:
  - _foo/bar.md
  - hello_world.md
```
## Defaults

### - Collection

If a collection is not designated as `{ versioned=>true }` in `_config.yml` then a default collection with the label `versioned_files` and the following metadata will be set.

- If using Travis CI to create the files only, this must be set in the `_config.yml` so gh-pages adds the collection when renders the site.

```yaml

collections:
  versioned_files:
    output: false
    permalink: /:collection/:path/
    versioned: true
```
### - Front Matter

- The files Front Matter `permalink` key is changed to `orig_permalink` (if present) to prevent it from rendering out to that location. Change the name in the `_config`
- A Front Matter key `sha` is added with the file's commit hash. Change the key name or remove it with the `git_versioned_frontmatter` setting
- A Front Matter key `ver` is added with the revision version number. Change the key name or remove it with the `git_versioned_frontmatter` setting

```yaml
git_versioned_frontmatter:
  permalink: orig_permalink
  sha: [ sha | false ]
  ver: [ ver | false ]
```

## Usage

Versioned files are created at `site.source/_collection_labelname/v#/filename.ext`.
- `path/filename` is flattened in the versioned-files collection to `path_filename.ext`

```
# created directory & file structure

site.source
  _collection_labelname
    v1
      _foo_bar.md
      hello_world.md
    v2
      _foo_bar.md
      hello_world.md
    v3
      hello_world.md

    etc
```

The collection and documents/files can be accessed using [Jekyll Liquid](https://learn.cloudcannon.com/jekyll-cheat-sheet/) output for [collections](https://jekyllrb.com/docs/collections/):

```liquid
{{ site.collection_labelname }}

<!-- Loop through the versioned-files _collection[documents] -->
{% for doc in site.collection_name.docs %}
  {{ doc.relative_path }}: {{ doc.content }}
  <hr>
{% end for %}
```

### GitHub Pages + jekyll-versioned_files w/ Travis CI

As custom plugins do not work with GitHub Pages alone,
[Travis CI](https://travis-ci.org) can be used with the plugin to create the `_collection/v#/files` in the GitHub Pages repository - for GitHub Pages to access.

[Travis CI w/ GitHub deployment](https://docs.travis-ci.com/user/deployment/pages/) will create the `_collection/v#/files` and add it to the source branch in the GitHub Pages repo.

Create a `.travis.yml` and set the `Environment Variable:` `$GITHUB_TOKEN` in Travis CI settings with a [GitHub Access Token](https://github.com/settings/tokens).

```yaml
# sample `.travis.yml`

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
