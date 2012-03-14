class RepoPresenter

  attr_reader :repo

  def initialize(repo)
    @repo = repo
  end

  def commit_count
    @repo.commits.count
  end

  def cache_count
    @repo.git_fix_cache.cache.cache.count
  end

  def last_updated
    @repo.commits.last.updated_at
  end

  def total_complexity
    @repo.commits.sum(:complexity)
  end

end