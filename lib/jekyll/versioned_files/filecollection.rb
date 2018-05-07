require 'jekyll'

module Jekyll
  module VersionedFiles
    class FileCollection < Jekyll::Collection
      # Create a new Jekyll::Collection.
      #
      # site - the site to which this collection belongs.
      #
      # Returns nothing.
      def initialize(site)
        @site     = site
        @label    = sanitize_label(VersionedFiles.collection_label)
        @metadata = VersionedFiles.collection_metadata

        VersionedFiles.collection_dir = File.join(@site.source, "_#{@label}")
        VersionedFiles.make_dir(VersionedFiles.collection_dir)
      end
    end
  end
end
