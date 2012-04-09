require 'grit'
require 'rugged'

module Bugwatch

  class GitAnalyzer

    include FileHelper

    REPOS_DIR = "repos"

    attr_writer :caching_strategy
    attr_reader :on_commit

    def initialize(repo_name, repo_url)
      @repo_name = repo_name
      @repo_url = repo_url
      @on_commit = []
    end

    def repo
      @repo ||= get_repo
    end

    def add(commit_sha)
      unless caching_strategy.commit_exists?(commit_sha)
        update_repo
        new_commits(commit_sha).each &method(:run_callbacks)
      end
    end

    def caching_strategy
      @caching_strategy ||= FileSystemCache.new(@repo_name)
    end

    private

    def new_commits(new_commit_sha)
      if caching_strategy.cache_exists?
        mine_for_commits(new_commit_sha).take(1)
      else
        mine_for_commits(new_commit_sha)
      end
    end

    def mine_for_commits(new_commit_sha)
      Enumerator.new do |y|
        rugged_repo.walk(new_commit_sha).each do |rugged_commit|
          grit_commit = repo.commit(rugged_commit.oid)
          y << grit_commit
        end
      end
    end

    def rugged_repo
      @rugged_repo ||= Rugged::Repository.new(path_to_repo)
    end

    def run_callbacks(c)
      unless merge_commit? c
        bugwatch_commit = Commit.new(c)
        on_commit.each { |callback| callback.call(bugwatch_commit) }
        caching_strategy.store(bugwatch_commit)
      end
    end

    def merge_commit?(commit)
      commit.parents.count > 1
    end

    def path_to_repo
      "#{REPOS_DIR}/#{@repo_name}"
    end

    def get_repo
      unless File.exists?(path_to_repo)
        Kernel.system("cd #{REPOS_DIR}; git clone #{@repo_url}")
      end
      Grit::Repo.new(path_to_repo)
    end

    def update_repo
      Kernel.system("cd #{path_to_repo}; git pull origin master")
    end

  end

end