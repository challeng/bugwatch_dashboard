require 'set'

class ActiveRecordCache

  def initialize(repo)
    @repo = repo
  end

  def cache_exists?
    @repo.bug_fixes.any?
  end

  def retrieve
    @repo.bug_fixes.map {|bug_fix| Bugwatch::BugFix.new(:sha => bug_fix.commit.sha, :file => bug_fix.file,
                          :klass => bug_fix.klass, :function => bug_fix.function, :date => bug_fix.date_fixed) }
  end

  def store(bug_fixes)
    new_bug_fix_shas = Set[*bug_fixes.map(&:sha)] - Set[*@repo.commits.joins(:bug_fixes).map(&:sha)]
    new_bug_fixes = bug_fixes.select { |bug_fix| new_bug_fix_shas.include?(bug_fix.sha) }
    new_bug_fixes.each do |bug_fix|
      commit = @repo.commits.find_by_sha(bug_fix.sha)
      BugFix.create(:commit => commit, :file => bug_fix.file, :klass => bug_fix.klass, :function => bug_fix.function,
                   :date_fixed => bug_fix.date)
    end
  end

end