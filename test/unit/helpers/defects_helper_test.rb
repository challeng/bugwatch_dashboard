require 'test_helper'

class DefectsHelperTest < ActionView::TestCase

  attr_reader :start_date

  def setup
    @start_date = DateTime.new(2010, 10, 10)
  end

  test ".grouped_by_release groups defects by their releases" do
    release1 = Release.new(deploy_date: start_date)
    release2 = Release.new(deploy_date: start_date + 2.days)
    before_release_defect = Defect.new(date: start_date - 1.day)
    defect2 = Defect.new(date: start_date)
    defect3 = Defect.new(date: start_date + 1.day)
    after_release_defect = Defect.new(date: start_date + 3.days)
    expected = {release1 => [defect2, defect3], release2 => [after_release_defect]}
    assert_equal expected, grouped_by_release([release1, release2], [before_release_defect, defect2, defect3, after_release_defect])
  end

  test ".graph_grouped_values returns json array of release and defect data" do
    release = Release.new(deploy_date: start_date)
    release2 = Release.new(deploy_date: start_date + 2.days)
    defect = Defect.new(date: release.deploy_date, ticket_id: 123, status: Defect::OPEN)
    defect2 = Defect.new(date: release2.deploy_date, ticket_id: 456, status: Defect::CLOSED)
    expected = [{"name" => "Open", "data" => [1, 0]}, {"name" => "Closed", "data" => [0, 1]}]
    assert_equal expected.to_json, graph_grouped_values([release, release2], [defect, defect2])
  end

end
