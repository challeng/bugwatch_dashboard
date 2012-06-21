require 'test_helper'
require 'api/pivotal_api'

class PivotalApiTest < Test::Unit::TestCase

  test ".defects calls stories api with a bug filter" do
    sut = PivotalApi
    project_id = 999
    HTTParty.expects(:get).with("http://www.pivotaltracker.com/services/v3/projects/#{project_id}/stories?filter=type:bug").
            returns("")
    sut.defects(project_id)
  end

end