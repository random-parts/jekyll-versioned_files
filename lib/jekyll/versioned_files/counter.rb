module Jekyll
  module VersionedFiles
    class Counter
      attr_reader :del, :final, :ins
    
      def initialize
        @del = 0
        @ins = 0
      end 

      def del
        @del += 1
      end

      def ins
        @ins += 1
      end

      def final
        {
          "diff_del" => @del,
          "diff_ins" => @ins
        }
      end
    end
  end
end
