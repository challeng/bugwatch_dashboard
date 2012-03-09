module ReposHelper

  def aggregate_complexity_for_graph(repo_name, complexity)
    data = complexity.inject([]) do |collection, c|
      collection + [c + (collection.last || 0)]
    end
    [{:name => repo_name, :data => data}].to_json
  end

end
