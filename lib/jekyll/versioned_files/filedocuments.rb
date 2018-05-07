module Jekyll
  module VersionedFiles
    class FileDocuments
      YAML_REGEXP = %r!\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)!m

      # Initialize FileDocument.
      #
      # site - the site to which these documents belongs.
      #
      # Returns nothing.
      def initialize(site)
        files = VersionedFiles.files

        @site        = site
        @source_dir  = site.source
        @fname_paths = files.kind_of?(Array) ? files : files.scan(/.+/)
        @fm_mods     = VersionedFiles.frontmatter
      end

      # Creates the collection of versioned files in site.source directory
      #
      # Returns nothing
      def create
        fname = @fname_paths.each do |e| e.split("/").last
          revisions(e).each_with_index do |sha, i|
            ver = (i + 1).to_s
            version_dir = File.join(VersionedFiles.collection_dir, 'v' + ver)
            file_path = File.join(version_dir, flatten(e))

            # dont re-write files
            next hash if File.exist?(file_path)
            VersionedFiles.make_dir(version_dir)

            write(file_path, versioned_content(e, sha, ver))
          end
        end
      end

      private
      def flatten(fname_path)
        fname_path.gsub("/", "_")
      end

      # Modify the versioned files' yaml front matter
      #
      # content - File content
      # sha - current files commit hash
      # ver - the number repersenting the files revision version
      #
      # Returns modified front matter
      private
      def modify_frontmatter(front_matter, sha, ver)
        front_matter.sub(/permalink/, @fm_mods['permalink'])

        modify_fm_variable(front_matter, "ver", ver) if @fm_mods["ver"]
        modify_fm_variable(front_matter, "sha", sha) if @fm_mods["sha"]
      end

      private
      def modify_fm_variable(front_matter, key, val)
        front_matter.sub!(YAML_REGEXP, '\1' +@fm_mods[key]+ ': ' +val+ "\n" + '\2')
      end

      private
      def revisions(fname_path)
          all_sha = %x{ git rev-list --all #{fname_path} }.split("\n").reverse!
      end

      # Collects the file content by its git commit hash
      #
      # fname_path - the `path/filename` to process
      # sha - current fname_path's commit hash
      # ver - the number repersenting the fname_path's revision version
      #
      # Returns file content to be writen
      private
      def versioned_content(fname_path, sha, ver)
        content = %x{ git cat-file -p #{sha}:#{fname_path} }.strip
        front_matter = content.match(YAML_REGEXP).to_s

        content.sub!(YAML_REGEXP, modify_frontmatter(front_matter, sha, ver)) unless front_matter.empty?
        content
      end

      private
      def write(path, content)
        File.write(path, content)
      end
    end
  end
end
