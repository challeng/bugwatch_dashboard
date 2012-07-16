require 'rack_test_helper'
require 'support/pivotal_xml'

class PivotalHookTest < Test::Unit::TestCase
  include RackTest

  test "POST /pivotal parses xml and enqueues pivotal defect worker" do
    story_id = "123"
    project_id = "999"
    event_type = "story_update"
    story_type = "bug"
    current_state = "finished"
    params = {id: story_id, project_id: project_id, event_type: event_type,
            story_type: story_type, current_state: current_state}
    pivotal_xml = PivotalXml.story params
    Resque.expects(:enqueue).with(PivotalDefectWorker, params)
    post "/pivotal", {:body => pivotal_xml}
  end

  test "POST /pivotal logs exceptions" do
    Resque.stubs(:enqueue).with(anything).raises(StandardError)
    Rails.logger.expects(:error).with(anything)
    post "/pivotal", {:body => ""}
    assert_equal last_response.body, "OK"
  end

end