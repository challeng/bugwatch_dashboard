require 'test_helper'
require 'api/pivotal_api'

class PivotalApiTest < Test::Unit::TestCase

  test ".defects calls stories api with a bug filter and api token" do
    sut = PivotalApi
    project_id = 999
    token = "XXX"
    response = stub("Response", :body => "yay response")
    HTTParty.expects(:get).with("https://www.pivotaltracker.com/services/v3/projects/#{project_id}/stories?filter=type:bug",
                                {"X-TrackerToken" => token}).returns(response)
    result = sut.defects(project_id, token)
    assert_equal "yay response", result
  end

end