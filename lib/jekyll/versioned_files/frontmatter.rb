module Jekyll
  module VersionedFiles
    class FrontMatter
      attr_accessor  :data, :frontmatter, :new_data, :content

      def data
        @data ||= {}
      end

      def frontmatter
        @frontmatter = content.match(FRONTMATTER_REGEXP)[1] || nil 
      end

      FRONTMATTER_REGEXP = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m
      # Initialize FileDocument.
      #
      # Returns nothing.
      def initialize(new_data)
        @data     = {} 
        @fm_mods  = VersionedFiles.frontmatter
        @new_data = new_data || {}
      end

      # Updates the content's Front Matter
      #
      # Returns content with updated Front Matter
      def update
        mod_key("permalink") if data.has_key?("permalink") && @fm_mods["permalink"]
        merge_data
        @content.sub!(FRONTMATTER_REGEXP, to_frontmatter) || @content
      end

      # Creates a new Front matter block
      #
      # Returns content with updated Front Matter
      def create
        merge_data  
        to_frontmatter 
      end

      private
      def merge_data
        @new_data.each do |k,v|
          next if !@fm_mods[k]
          @data[@fm_mods[k]] = v # @new_data[k]
        end
      end

      private
      def to_frontmatter
        @data.to_yaml + "---\n\n"
      end

      private
      def to_data(content)
        @data = SafeYAML.load(content) unless content.nil?
      end

      private
      def mod_key(key)
        if frontmatter
          @data = SafeYAML.load(frontmatter[1].sub!(/#{key}/, @fm_mods[key]))
        end
      end
    end
  end
end
