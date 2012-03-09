module ReposHelper

  def aggregate_complexity_for_graph(repo_name, complexity)
    data = complexity.inject([]) do |collection, c|
      collection + [c + (collection.last || 0)]
    end
    [{:name => repo_name, :data => data}].to_json
  end

  def fix_cache_graph_data(hot_spots)
    hot_spots.map do |hot_spot|
      {:name => hot_spot.file, :data => [hot_spot.bug_fixes.sum(&:score)]}
    end.to_json
  end

end
