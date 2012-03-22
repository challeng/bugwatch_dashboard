module Bugwatch

  class GitFixCache

    include FileHelper

    REPOS_DIR = "repos"
    COMMIT_CHUNK_SIZE = 200

    attr_writer :caching_strategy
    attr_accessor :on_commit

    def initialize(repo_name, repo_url)
      @repo_name = repo_name
      @repo_url = repo_url
    end

    def cache
      @cache ||= get_loaded_fix_cache
    end

    def repo
      @repo ||= get_repo
    end

    def add(commit_sha)
      unless bug_fixes_in_cache.map(&:sha).include?(commit_sha)
        update_repo
        commit = repo.commit(commit_sha)
        cache.add(*get_bug_fixes_from_commit(commit))
      end
    end

    def caching_strategy
      @caching_strategy ||= FileSystemCache.new(@repo_name)
    end

    def write_bug_cache
      caching_strategy.store(bug_fixes_in_cache)
    end

    def alerts(commit_sha)
      commit = repo.commit(commit_sha)
      commit_files = commit.stats.files.map(&:first)
      hot_spots = cache.hot_spots.select {|hot_spot| commit_files.include?(hot_spot.file) }
      diffs = commit.diffs.select {|diff| hot_spots.map(&:file).include?(diff.b_path) }
      hot_spots.sort_by(&:file).zip(diffs.sort_by(&:b_path)).flat_map do |(hot_spot, diff)|
        Bugwatch::DiffParser.parse_class_and_functions(diff).flat_map do |(klass, methods)|
          hot_spot.bug_fixes.select {|bug_fix| bug_fix.klass == klass && methods.include?(bug_fix.function) }
        end
      end
    end

    private

    def get_loaded_fix_cache
      fix_cache = FixCache.new(files.count)
      fix_cache.preload(get_preload_files(fix_cache.cache_limit)) unless caching_strategy.cache_exists?
      fix_cache.add(*bug_fixes)
      fix_cache
    end

    def bug_fixes
      if caching_strategy.cache_exists?
        caching_strategy.retrieve
      else
        mine_for_bug_fixes
      end
    end

    def mine_for_bug_fixes
      all_commits.flat_map do |commit|
        get_bug_fixes_from_commit(commit)
      end
    end

    def get_bug_fixes_from_commit(commit)
      bug_fixes = Bugwatch::FixCommit.new(commit).fixes
      on_commit.call(commit, bug_fixes) if on_commit
      bug_fixes
    end

    def all_commits
      Enumerator.new do |y|
        reverse_offset(repo.commit_count) do |offset|
          repo.commits('master', COMMIT_CHUNK_SIZE, offset).each do |commit|
            y << commit unless merge_commit?(commit)
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

    def merge_commit?(commit)
      commit.parents.count > 1
    end

    def path_to_repo
      "#{REPOS_DIR}/#{@repo_name}"
    end

    def files
      @files ||= get_files(repo.tree.contents)
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

    def get_files(contents)
      contents.reduce([]) do |count, type|
        if type.is_a?(Grit::Blob) && ruby_file?(type.name)
          count + [[type.name, type.size]]
        elsif type.is_a?(Grit::Tree)
          count + get_files(type.contents)
        else
          count
        end
      end
    end

    def get_preload_files(cache_limit)
      files.sort_by {|_, size| -size}.take(cache_limit).map(&:first)
    end

    def bug_fixes_in_cache
      cache.cache.values.flatten
    end

  end

end