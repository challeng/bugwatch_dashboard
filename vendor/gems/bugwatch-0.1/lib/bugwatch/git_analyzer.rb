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
      commits(commit_sha, true).each do |commit|
        caching_strategy.store(commit)
      end
    end

    def caching_strategy
      @caching_strategy ||= FileSystemCache.new(@repo_name)
    end

    def commits(begin_sha, follow_merge=false)
      Enumerator.new do |y|
        filtered_commits(begin_sha, follow_merge).each do |commit|
          bugwatch_commit = Commit.new(commit)
          run_callbacks(bugwatch_commit)
          y << bugwatch_commit
        end
      end
    end

    private

    def filtered_commits(begin_sha, follow_merge)
      Enumerator.new do |y|
        mine_for_commits(begin_sha).each do |commit|
          break if caching_strategy.commit_exists? commit.sha
          if merge_commit?(commit) && follow_merge
            commit.parents.each do |parent|
              filtered_commits(parent.sha, follow_merge).each {|c| y << c }
            end
          else
            y << commit
          end
        end
      end
    end

    def mine_for_commits(new_commit_sha)
      update_repo
      Enumerator.new do |y|
        repo.walk(new_commit_sha).each do |rugged_commit|
          grit_commit = repo.commit(rugged_commit.oid)
          y << grit_commit
        end
      end
    end

    def run_callbacks(bugwatch_commit)
      on_commit.each { |callback| callback.call(bugwatch_commit) }
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
      Repo.new(path_to_repo)
    end

    def update_repo
      Kernel.system("cd #{path_to_repo}; git pull origin master; git fetch --tags")
    end

  end

end