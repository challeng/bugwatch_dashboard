module Bugwatch

  class FixCommit

    attr_reader :commit

    def initialize(commit)
      @commit = commit
    end

    def files
      commit.stats.files.map(&:first)
    end

    def ruby_files
      files.select { |file| file.match(/\.rb$/) && !file.match(/^spec\//) }
    end

    def fix_commit?
      commit.short_message =~ /((^fix|\sfix)(es|ed)?)|\sbug(s)?/
    end

    def get_bug_fixes(diff, file)
      DiffParser.parse_class_and_functions(diff).flat_map do |klass, methods|
        methods.map { |function|
          BugFix.new(:file => file, :date => commit.committed_date, :sha => commit.sha,
                     :klass => klass, :function => function) }
      end
    rescue Racc::ParseError, SyntaxError
      []
    end

    def fixes
      return [] unless fix_commit?
      ruby_files.inject([]) do |bug_fixes, file|
        diff = commit.diffs.find{|d| d.b_path == file}
        if diff
          bug_fixes + get_bug_fixes(diff, file)
        else
          bug_fixes
        end
      end
    end

  end

end