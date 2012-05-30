require 'grit'
require 'uri'

class Repo < ActiveRecord::Base

  has_many :commits, :dependent => :destroy
  has_many :subscriptions, :dependent => :destroy
  has_many :users, :through => :subscriptions
  has_many :alerts, :through => :commits
  has_many :bug_fixes, :through => :commits

  REPO_DIR = "repos"

  def git_analyzer
    @git_fix_cache ||= get_prepared_git_analyzer
  end

  def hot_spots
    @hot_spots ||= self.fix_cache.hot_spots
  end

  def fix_cache
    @fix_cache ||= Bugwatch::FixCacheAnalyzer.new(grit, self.bug_fixes.map(&:bugwatch)).cache
  end

  def tags
    grit.tags
  end

  def grit
    Grit::Repo.new(path)
  end

  def path
    "#{REPO_DIR}/#{self.name}"
  end

  private

  def get_prepared_git_analyzer
    fix_cache = Bugwatch::GitAnalyzer.new(self.name, url_for_protocol)
    fix_cache.caching_strategy = ActiveRecordCache.new(self)
    fix_cache
  end

  def url_for_protocol
    uri = URI(self.url.gsub("git@", ""))
    if AppConfig.git_domains.include?(uri.host)
      "#{uri.host}:#{uri.path}"
    else
      self.url
    end
  end

end
