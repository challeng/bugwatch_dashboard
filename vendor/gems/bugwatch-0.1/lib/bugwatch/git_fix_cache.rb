module Bugwatch

  class GitFixCache

    REPOS_DIR = "repos"
    CACHE_DIR = "cache"
    COMMIT_CHUNK_SIZE = 500

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

    def add(commit)
      unless fixes_in_cache.map(&:sha).include?(commit.sha)
        fix_commit = FixCommit.new(commit)
        cache.add(*fix_commit.fixes)
      end
    end

    def write_bug_cache
      File.open(path_to_cache, 'w') {|f| f.write(JSON.dump(fixes_in_cache.map(&:to_json))) }
    end

    private

    def get_loaded_fix_cache
      fix_cache = FixCache.new(files.count)
      fix_cache.preload(get_preload_files(fix_cache.cache_limit)) unless File.exists?(path_to_cache)
      fix_cache.add(*bug_fixes)
      fix_cache
    end

    def bug_fixes
      if File.exists?(path_to_cache)
        cached_bugs
      else
        mine_for_bug_fixes
      end
    end

    def cached_bugs
      JSON.parse(File.read(path_to_cache)).map do |bug_fix_metadata|
        BugFix.new(bug_fix_metadata)
      end
    end

    def mine_for_bug_fixes
      all_commits.flat_map do |commit|
        Bugwatch::FixCommit.new(commit).fixes
      end
    end

    def all_commits
      Enumerator.new do |y|
        ((repo.commit_count / COMMIT_CHUNK_SIZE) + 1).times do |offset|
          repo.commits('master', COMMIT_CHUNK_SIZE, offset * COMMIT_CHUNK_SIZE).each do |commit|
            y << commit
          end
        end
      end
    end

    def path_to_repo
      "#{REPOS_DIR}/#{@repo_name}"
    end

    def files
      @files ||= get_files(repo.tree.contents)
    end

    def get_repo
      if File.exists?(path_to_repo)
        Kernel.system("cd #{path_to_repo}; git pull origin master")
      else
        Kernel.system("cd #{REPOS_DIR}; git clone #{@repo_url}")
      end
      Grit::Repo.new(path_to_repo)
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

    def fixes_in_cache
      cache.cache.values.flatten
    end

    def path_to_cache
      "#{CACHE_DIR}/#{@repo_name}.json"
    end

    def ruby_file?(file)
      file.match(/\.rb$/) && !file.match(/_spec|_steps\.rb$/)
    end

  end

end