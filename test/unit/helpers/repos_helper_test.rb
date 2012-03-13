require 'test_helper'

class ReposHelperTest < ActionView::TestCase

  test "#aggregate_complexity_for_graph returns json of accumulated sums and repo name" do
    expected = [{:name => "test", :data => [1, 3, 6]}].to_json
    assert_equal expected, aggregate_complexity_for_graph("test", [1, 2, 3])
  end

  test "#fix_cache_graph_data returns json with files and accumulated scores" do
    hot_spot = Bugwatch::HotSpot.new('file1.rb', [stub(:score => 1), stub(:score => 2)])
    hot_spot2 = Bugwatch::HotSpot.new('file2.rb', [stub(:score => 5), stub(:score => 6)])
    expected = [{:name => "file1.rb", :data => [3]}, {:name => "file2.rb", :data => [11]}].to_json
    assert_equal expected, fix_cache_graph_data([hot_spot, hot_spot2])
  end

  test "#commit_complexity_graph_data returns json with files and accumulated scores" do
    expected = [{:name => "file.rb", :data => [5]}, {:name => "file2.rb", :data => [8]}].to_json
    assert_equal expected, commit_complexity_graph_data([["file.rb", 5], ["file2.rb", 8]])
  end

end
