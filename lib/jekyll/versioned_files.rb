require 'jekyll/versioned_files/counter'
require 'jekyll/versioned_files/filecollection'
require 'jekyll/versioned_files/filedocuments'
require 'jekyll/versioned_files/frontmatter'
require 'jekyll/versioned_files/styler'
require 'jekyll/versioned_files/version'

module Jekyll
  module VersionedFiles
    class << self
      attr_accessor :config_collection, :collection_dir, :collection_label,
                    :collection_metadata, :config_options, :diff_limit,
                    :files, :format_options, :frontmatter
    end

    ERROR_MSG = {
      :Argument_options => "Missing `versioned_file_options` in config. Please update your _config.yml",
      :Argument_files => "Missing a `versioned_file_options['files']` value in config. "\
                         "Please update your _config.yml with a file to process."
    }.freeze

    COLLECTION_LABEL = "versioned_files"

    COLLECTION_METADATA = {
      "output"    => false,
      "permalink" => "/:collection/:path/",
      "versioned" => true
    }.freeze

    FORMAT_OPTIONS = {
      "diff_ignore" => {
        "ignore-all-space"    => false,
        "ignore-blank-lines"  => true,
        "ignore-space-change" => true
      },
      "diff_limit" => false,
      "output" => "markdown"
    }.freeze

    FRONTMATTER = {
      "permalink" => "orig_permalink",
      "no_change" => "no_change",
      "diff_del" => "diff_del",
      "diff_ins" => "diff_ins",
      "sha"       => "sha",
      "ver"       => "ver"
    }.freeze

    CONFIG_OPTIONS = {
      "frontmatter" => FRONTMATTER,
      "formatting" => FORMAT_OPTIONS
    }.freeze

    def self.make_dir(dir)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
    end

    def self.merge!(default, new_hash)
      Jekyll::Utils.deep_merge_hashes!(default, new_hash)
    end

    # Jekyll::Hook
    #
    # site - the site to which this collection belongs.
    #
    # Sets the versions files, collection into the site config and site source
    Jekyll::Hooks.register :site, :after_init do |site|
      self.config_collection = site.config['collections'].find{ |k, h| h['versioned'] }.to_a

      raise ArgumentError, ERROR_MSG[:Argument_options] unless site.config['versioned_file_options']
      raise ArgumentError, ERROR_MSG[:Argument_files] unless site.config['versioned_file_options']['files']

      self.collection_label    = config_collection.empty? ? COLLECTION_LABEL : config_collection[0]
      self.collection_metadata = merge!(COLLECTION_METADATA.dup, config_collection.last.to_h)
      self.config_options      = merge!(CONFIG_OPTIONS.dup, site.config['versioned_file_options'])
      self.files               = config_options['files']
      self.files               = files.kind_of?(Array) ? files : files.scan(/.+/)
      self.frontmatter                   = config_options['frontmatter']
      self.format_options                = config_options['formatting']
      self.format_options['diff_ignore'] = diffignore

      collection = FileCollection.new(site)
      # Merge versioned collection values into site.config,
      # only adds values not in the _config.yml
      merge!(site.config['collections'], {collection.label=>{collection.label=>collection.metadata}})

      FileDocuments.new.create
    end

    private_class_method def self.diffignore
      opts = format_options['diff_ignore'].select{ |k, v| v == true }.keys.join(" --")
      "--" + opts unless opts.empty?
    end
  end
end
