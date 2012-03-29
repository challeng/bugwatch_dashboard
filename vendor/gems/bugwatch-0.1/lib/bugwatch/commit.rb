module Bugwatch

  class Commit

    include FileHelper

    attr_reader :grit

    def initialize(grit)
      @grit = grit
    end

    def sha
      @grit.sha
    end

    def fixes
      return [] unless keywords_in_commit_message?
      @fixes ||= ruby_files.inject([]) do |bug_fixes, file|
        diff = grit.diffs.find{|d| d.b_path == file}
        if diff
          bug_fixes + get_bug_fixes(diff, file)
        else
          bug_fixes
        end
      end
    end

    private

    def get_bug_fixes(diff, file)
      DiffParser.parse_class_and_functions(diff).flat_map do |klass, methods|
        methods.map { |function|
          BugFix.new(:file => file, :date => grit.committed_date, :sha => grit.sha,
                     :klass => klass, :function => function) }
      end
    rescue Racc::ParseError, SyntaxError
      []
    end

    def files
      grit.stats.files.map(&:first)
    end

    def ruby_files
      files.select { |file| ruby_file?(file) }
    end

    def keywords_in_commit_message?
      grit.short_message =~ /((^fix|\sfix)(es|ed)?)|\sbug(s)?/
    end

  end

end