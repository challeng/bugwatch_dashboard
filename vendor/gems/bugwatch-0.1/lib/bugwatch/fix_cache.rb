module Bugwatch

  class FixCache

    attr_reader :cache

    def initialize(file_count, limit=10)
      @cache = Hash.new {|h, k| h[k] = []}
      @file_count = file_count
      @limit = limit
    end

    def preload(preload_cache)
      preload_cache.each do |file_name|
        @cache[file_name] = []
      end
    end

    def add(*fixes)
      fixes.each do |fix|
        @cache[fix.file] << fix
      end
    end

    def hot_files
      hot_spots.map(&:file)
    end

    def hot_spots
      cache.sort_by do |_, fixes|
        -weight(fixes)
      end.take(cache_limit).map do |(file, bug_fixes)|
        HotSpot.new(file, bug_fixes)
      end
    end

    def weight(fixes)
      fixes.reduce(0.0) do |total, fix|
        total + fix.score
      end
    end

    def cache_limit
      (@file_count * (@limit.to_f / 100)).to_i
    end

  end
end