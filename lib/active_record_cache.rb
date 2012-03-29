require 'set'

class ActiveRecordCache

  def initialize(repo)
    @repo = repo
  end

  def commit_exists?(commit_sha)
    @repo.commits.find_by_sha(commit_sha)
  end

  def cache_exists?
    @repo.commits.any?
  end

  def retrieve
    @repo.bug_fixes.includes(:commit).map {|bug_fix| Bugwatch::BugFix.new(:sha => bug_fix.commit.sha, :file => bug_fix.file,
                          :klass => bug_fix.klass, :function => bug_fix.function, :date => bug_fix.date_fixed.to_s) }

  end

  def store(bugwatch_commit)
    commit = @repo.commits.find_by_sha(bugwatch_commit.sha)
    bugwatch_commit.fixes.each do |bug_fix|
      BugFix.find_or_create_by_file_and_klass_and_function_and_commit_id(
          bug_fix.file, bug_fix.klass, bug_fix.function, commit.id, :date_fixed => bug_fix.date)
    end
  end

end