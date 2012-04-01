module Bugwatch

  class GitAnalyzer

    include FileHelper

    REPOS_DIR = "repos"
    COMMIT_CHUNK_SIZE = 200

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
        commit = repo.commit(commit_sha)
        new_commits(commit).each &method(:run_callbacks)
      end
    end

    def caching_strategy
      @caching_strategy ||= FileSystemCache.new(@repo_name)
    end

    private

    def new_commits(new_commit)
      if caching_strategy.cache_exists?
        [new_commit]
      else
        mine_for_commits(new_commit)
      end
    end

    def mine_for_commits(new_commit)
      Enumerator.new do |y|
        catch :done do
          reverse_offset(repo.commit_count) do |offset|
            repo.commits('master', COMMIT_CHUNK_SIZE, offset).each do |commit|
              y << commit
              throw :done if commit.sha == new_commit.sha
            end
          end
        end
      end
    end

    def reverse_offset(commit_count)
      ((commit_count / COMMIT_CHUNK_SIZE) + 1).times do |offset|
        _offset = commit_count - (COMMIT_CHUNK_SIZE * offset)
        if commit_count < COMMIT_CHUNK_SIZE || _offset < 0
          yield 0
        else
          yield _offset
        end
      end
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