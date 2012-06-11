module Bugwatch

  class Diff

    def initialize(diff)
      @diff = diff
    end

    def identify(line_number)
      parse_class_and_functions([line_number..line_number])
    end

    def modifications
      parse_class_and_functions(line_numbers_of_changes)
    end

    def path
      @diff.b_path
    end

    private

    def parse_class_and_functions(line_range=nil)
      line_range.inject({}) do |hsh, lines|
        hsh.merge(MethodParser.find(@diff.b_blob.data, lines)) do |_, a, b|
          a + b
        end
      end
    end

    def line_numbers_of_changes
      @diff.diff.scan(/@@ -\d+,\d+\s\+(\d+),(\d+)/).map do |(start_line, length)|
        begin_length = start_line.to_i + 3
        end_length = length.to_i - 3
        if begin_length > end_length
          (begin_length)..(length.to_i + 3)
        else
          (begin_length)..(end_length)
        end
      end
    end

  end

end