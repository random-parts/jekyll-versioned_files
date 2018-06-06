module Jekyll
  module VersionedFiles
    class Styler
      DIFF_REGEX = %r!(\{\+)(.+?)(\+\})|(\[-)(.+?)(-\])!m

      OUTPUT_STYLE = {
        "markdown" => {
          "add" => ['**','**'],
          "del" => ['~~','~~']
        },
        "html" => {
          "add" => ["<ins>", "</ins>"],
          "del" => ["<del>", "</del>"]
        }
      }.freeze
      # Initialize FileDocument.
      #
      # Returns nothing.
      def initialize
        @output  = VersionedFiles.format_options['output']
        @fm_mods = VersionedFiles.frontmatter
      end

      def style(content)
        styled = content.gsub(DIFF_REGEX) do |m|
          if $1 == "{+" && $3 == "+}"
            "#{OUTPUT_STYLE[@output]['add'][0]}#{$2}#{OUTPUT_STYLE[@output]['add'][1]}"
          elsif $4 == "[-" && $6 == "-]"
            "#{OUTPUT_STYLE[@output]['del'][0]}#{$5}#{OUTPUT_STYLE[@output]['del'][1]}"
          end
        end
        styled || content
      end
    end
  end
end
