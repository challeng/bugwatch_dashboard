require 'grit'

class Repo < ActiveRecord::Base

  has_many :commits

  after_create :clone_repo

  REPO_DIR = "repos"

  def repo
    Kernel.system("cd #{REPO_DIR}/#{self.name}; git pull origin master")
    Grit::Repo.new("#{REPO_DIR}/#{self.name}")
  end

  private

  def clone_repo
    Kernel.system("mkdir #{REPO_DIR}; cd #{REPO_DIR}; git clone #{self.url}")
  end

end
