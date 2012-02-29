require 'grit'

class Repo < ActiveRecord::Base

  has_many :commits
  has_many :alerts, :through => :commits
  has_many :bug_fixes, :through => :commits

  after_create :clone_repo

  REPO_DIR = "repos"

  def repo
    @repo ||= get_grit_repo
  end

  def git_fix_cache
    @git_fix_cache ||= Bugwatch::GitFixCache.new(self.name, self.url)
  end

  private

  def clone_repo
    Kernel.system("mkdir #{REPO_DIR}; cd #{REPO_DIR}; git clone #{self.url}")
  end

  def get_grit_repo
    Kernel.system("cd #{REPO_DIR}/#{self.name}; git pull origin master")
    Grit::Repo.new("#{REPO_DIR}/#{self.name}")
  end


end
