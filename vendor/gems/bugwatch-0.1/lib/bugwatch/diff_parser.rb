module Bugwatch

  class DiffParser

    def self.parse_class_and_functions(diff)
      line_numbers = parse_line_numbers_of_changes(diff.diff)
      line_numbers.inject({}) do |hsh, line_range|
        merge(hsh, MethodParser.find(diff.b_blob.data, line_range))
      end
    end

    def self.parse_line_numbers_of_changes(diff_text)
      diff_text.scan(/@@ -\d+,\d+\s\+(\d+),(\d+)/).map do |(start_line, length)|
        begin_length = start_line.to_i + 3
        end_length = length.to_i - 3
        if begin_length > end_length
          (begin_length)..(length.to_i + 3)
        else
          (begin_length)..(end_length)
        end
      end
    end

    def self.merge(hash_a, hash_b)
      (hash_a.keys + hash_b.keys).uniq.inject({}) do |hsh, key|
        hsh.merge({key => (Array(hash_a[key]) + Array(hash_b[key]))})
      end
    end

  end

end