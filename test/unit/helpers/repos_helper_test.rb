require 'test_helper'

class ReposHelperTest < ActionView::TestCase

  test "#aggregate_complexity_for_graph returns json of accumulated sums and repo name" do
    expected = [{:name => "test", :data => [1, 3, 6]}].to_json
    assert_equal expected, aggregate_complexity_for_graph("test", [1, 2, 3])
  end

end
