require 'set'

class ActiveRecordCache

  def initialize(commit)
    @commit = commit
  end

  def cache_exists?
    @commit.bug_fixes.any?
  end

  def retrieve
    @commit.bug_fixes.map {|bug_fix| Bugwatch::BugFix.new(:sha => bug_fix.commit.sha, :file => bug_fix.file,
                                                          :klass => bug_fix.klass, :function => bug_fix.function, :date => bug_fix.date_fixed) }
  end

  def store(bug_fixes)
    new_bug_fix_shas = Set[*bug_fixes.map(&:sha)] - Set[*@commit.repo.commits.map(&:sha)]
    new_bug_fixes = bug_fixes.select { |bug_fix| new_bug_fix_shas.include?(bug_fix.sha) }
    new_bug_fixes.each do |bug_fix|
     BugFix.create(:commit => @commit, :file => bug_fix.file, :klass => bug_fix.klass, :function => bug_fix.function, :date_fixed => bug_fix.date)
    end
  end

end