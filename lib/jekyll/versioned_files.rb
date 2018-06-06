require 'jekyll/versioned_files/filecollection'
require 'jekyll/versioned_files/filedocuments'
require 'jekyll/versioned_files/version'

module Jekyll
  module VersionedFiles
    class << self
      attr_accessor :collection_dir, :collection_label, :collection_meta, :collection_metadata,
                    :config_collection, :files, :frontmatter
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

    FRONTMATTER = {
      "permalink" => "orig_permalink",
      "sha"       => "sha",
      "ver"       => "ver"
    }.freeze

    def self.make_dir(dir)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
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

      self.files = site.config['git_versioned_file']
      self.frontmatter = Jekyll::Utils.deep_merge_hashes(
                           FRONTMATTER,
                           site.config['git_versioned_frontmatter'] ||= {}
                         )

      self.collection_label = config_collection.empty? ? COLLECTION_LABEL : config_collection[0]
      self.collection_meta  = Jekyll::Utils.deep_merge_hashes(
                                COLLECTION_METADATA,
                                config_collection.last.to_h
                              )

      collection = FileCollection.new(site)
      # Merge versioned collection values into site.config,
      # only adds values not in the _config.yml
      Jekyll::Utils.deep_merge_hashes!(
        site.config['collections'],
        {collection.label=>{collection.label=>collection.metadata}}
      )

      FileDocuments.new(site).create
    end
  end
end
