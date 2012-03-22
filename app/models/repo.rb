require 'grit'

class Repo < ActiveRecord::Base

  has_many :commits
  has_many :subscriptions
  has_many :users, :through => :subscriptions
  has_many :alerts, :through => :commits
  has_many :bug_fixes, :through => :commits

  REPO_DIR = "repos"

  def git_fix_cache
    @git_fix_cache ||= get_prepared_git_fix_cache
  end

  def hot_spots
    self.git_fix_cache.cache.hot_spots
  end

  def tags
    grit.tags
  end

  def grit
    @grit ||= Grit::Repo.new(path)
  end

  def path
    "#{REPO_DIR}/#{self.name}"
  end

  private

  def get_grit_repo
    Grit::Repo.new(path)
  end

  def get_prepared_git_fix_cache
    fix_cache = Bugwatch::GitFixCache.new(self.name, self.url)
    fix_cache.caching_strategy = ActiveRecordCache.new(self)
    fix_cache
  end

end
