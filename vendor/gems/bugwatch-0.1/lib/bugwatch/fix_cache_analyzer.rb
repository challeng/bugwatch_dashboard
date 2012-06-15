module Bugwatch

  class FixCacheAnalyzer

    include FileHelper

    def initialize(repo, bug_fixes)
      @repo = repo
      @bug_fixes = bug_fixes
    end

    def call(commit)
      commit.fixes.each do |bug_fix|
        cache.add(bug_fix)
      end
    end

    def cache
      @cache ||= get_loaded_fix_cache
    end

    def alerts(commit_sha)
      commit = @repo.commit(commit_sha)
      commit_files = commit.stats.files.map(&:first)
      hot_spots = cache.hot_spots.select {|hot_spot| commit_files.include?(hot_spot.file) }
      diffs = commit.diffs.select {|diff| hot_spots.map(&:file).include?(diff.b_path) }
      hot_spots.sort_by(&:file).zip(diffs.sort_by(&:b_path)).flat_map do |(hot_spot, diff)|
        Bugwatch::Diff.new(diff).modifications.flat_map do |(klass, methods)|
          hot_spot.bug_fixes.select {|bug_fix| bug_fix.klass == klass && methods.include?(bug_fix.function) }
        end
      end
    end

    private

    def get_loaded_fix_cache
      fix_cache = FixCache.new(files.count)
      fix_cache.preload(get_preload_files(fix_cache.cache_limit))
      fix_cache.add(*@bug_fixes) unless @bug_fixes.empty?
      fix_cache
    end

    def files
      @files ||= get_files(@repo.tree.contents)
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

  end

end