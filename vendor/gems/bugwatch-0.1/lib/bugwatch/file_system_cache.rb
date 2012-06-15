module Bugwatch
  class FileSystemCache

    CACHE_DIR = "cache"

    def initialize(repo_name)
      @repo_name = repo_name
    end

    def store(commit)
      File.open(path_to_cache, 'w') {|f| f.write(JSON.dump(cache_json.merge({commit.sha => commit.fixes.map(&:to_json)}))) }
    end

    def cache_exists?
      File.exists?(path_to_cache)
    end

    def commit_exists?(commit_sha)
      cache_json.keys.include? commit_sha
    end

    def retrieve
      cache_json.flat_map do |(commit_sha, bug_fix_metadata)|
        bug_fix_metadata.map {|data| BugFix.new(data.merge('sha' => commit_sha)) }
      end
    end

    private

    def cache_json
      cache_exists? ?
        JSON.parse(File.read(path_to_cache)) :
        {}
    end

    def path_to_cache
      "#{CACHE_DIR}/#{@repo_name}.json"
    end

  end
end