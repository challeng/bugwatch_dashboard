module Bugwatch
  class FileSystemCache

    CACHE_DIR = "cache"

    def initialize(repo_name)
      @repo_name = repo_name
    end

    def store(bug_fixes)
      File.open(path_to_cache, 'w') {|f| f.write(JSON.dump(bug_fixes.map(&:to_json))) }
    end

    def cache_exists?
      File.exists?(path_to_cache)
    end

    def retrieve
      JSON.parse(File.read(path_to_cache)).map do |bug_fix_metadata|
        BugFix.new(bug_fix_metadata)
      end
    end

    def path_to_cache
      "#{CACHE_DIR}/#{@repo_name}.json"
    end

  end
end