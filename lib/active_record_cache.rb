require 'set'

class ActiveRecordCache

  def initialize(repo)
    @repo = repo
  end

  def cache_exists?
    @repo.commits.any?
  end

  def retrieve
    @repo.bug_fixes.includes(:commit).map {|bug_fix| Bugwatch::BugFix.new(:sha => bug_fix.commit.sha, :file => bug_fix.file,
                          :klass => bug_fix.klass, :function => bug_fix.function, :date => bug_fix.date_fixed.to_s) }

  end

end