module Bugwatch

  class HotSpot

    attr_reader :file, :bug_fixes

    def initialize(file, bug_fixes)
      @file = file
      @bug_fixes = bug_fixes
    end

    def classes
      @bug_fixes.select(&:klass).group_by(&:klass).map do |(klass, bug_fix)|
        [klass, bug_fix.map(&:score).reduce(:+)]
      end
    end

    def functions
      @bug_fixes.select(&:function).group_by(&:klass).each_with_object({}) do |(klass, bug_fixes), hsh|
        hsh[klass] = bug_fixes.group_by(&:function).map do |function, fixes|
          [function, fixes.map(&:score).reduce(:+)]
        end.sort_by {|(_, score)| -score}
      end
    end

  end

end
