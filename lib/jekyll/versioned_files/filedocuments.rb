module Jekyll
  module VersionedFiles
    class FileDocuments
      attr_reader   :diffoptions, :fname_paths
      attr_accessor :line_count

      DIFF_HEADER_REGEXP = %r!diff.+?@@.+?@@\n+?(?<=.)?!m

      # Initialize FileDocuments.
      #
      # Returns nothing.
      def initialize
        @diffoptions = VersionedFiles.format_options['diff_ignore']
        @fname_paths = VersionedFiles.files
        @style       = Styler.new
      end

      # Creates the collection of versioned files in site.source directory
      #
      # Returns nothing
      def create
        revisions do |orig_file, sha_list|
          sha_list.each_with_index do |sha, i|
            ver = (i + 1).to_s
            # Git revisioned file
            composeversions(orig_file, sha, ver) do |content, data, file_path|
              # dont re-write files
              if File.exist?(file_path)
                linecount(file_path)
                next
              end

              version_content = FrontMatter.new(data)
              version_content.content = content 
              write(file_path, version_content.update)
              linecount(file_path)
            end
          end

          sha_list.map!.with_index { |sha, i| [] << sha << (i + 1) }
          # Git Diff combination files
          composediffs(orig_file, line_count, sha_list.combination(2)) do |content, data, file_path|
            content.sub!(DIFF_HEADER_REGEXP, '')
            if change?(content)
              VersionedFiles.frontmatter["no_change"] = false
              styled_content = @style.style(content)
              data.merge!(@style.stats.final)
            else
              VersionedFiles.frontmatter["no_change"] = "no_change"
              data["no_change"] = true
            end

            fm = FrontMatter.new(data).create
            diff_file = fm << styled_content
            write(file_path, diff_file)
          end
        end
      end

      private
      def change?(content)
        !content.empty?
      end

      private
      def composediffs(orig_file, lines, sha_pairs)
        diff_dir = File.join(VersionedFiles.collection_dir, 'diffs')
        VersionedFiles.make_dir(diff_dir)
        # limit number of diff pairs
        if VersionedFiles.format_options['diff_limit']
          sha_pairs = sha_pairs.select { |pair| pair[1][1] - pair[0][1] == 1 }
        end
        
        sha_pairs.each do |pair|
          data = {
            "ver" => [pair[0][1], pair[1][1]],
            "sha" => [pair[0][0], pair[1][0]]
          }
          diff_ver_dir = File.join(diff_dir, 'v'+pair[0][1].to_s)
          file_name = 'v'+pair[0][1].to_s+'_v'+pair[1][1].to_s+'_'+flatten(orig_file)

          VersionedFiles.make_dir(diff_ver_dir)
          file_path = File.join(diff_ver_dir, file_name)
          yield diff(orig_file, lines, pair[0][0], pair[1][0]), data, file_path
        end
      end

      private
      def composeversions(orig_file, sha, ver)
        data = {"ver"=> ver, "sha"=> sha}

        version_dir = File.join(VersionedFiles.collection_dir, 'v'+ver)
        VersionedFiles.make_dir(version_dir)

        file_path = File.join(version_dir, flatten(orig_file))
        yield versioned_content(orig_file, sha), data, file_path
      end

      private
      def diff(orig_file, lines, old_sha, new_sha)
        %x{ git diff -U#{lines} --word-diff #{diffoptions} #{old_sha} #{new_sha} #{orig_file} }
      end

      private
      def flatten(orig_file)
        orig_file.gsub("/", "_").delete_prefix("_")
      end

      private
      def linecount(file_path)
        lc = %x{ wc -l < #{file_path} }.to_i
        self.line_count = lc unless line_count > lc
      end

      private
      def revisions
        fname_paths.each do |e|
          self.line_count = 0
          yield e, shalist(e)
        end
      end

      private
      def shalist(orig_file)
        %x{ git rev-list --all #{orig_file} }.split("\n").reverse!
      end

      private
      def versioned_content(orig_file, sha)
        %x{ git cat-file -p #{sha}:#{orig_file} }.strip
      end

      private
      def write(path, content)
        File.write(path, content)
      end
    end
  end
end
