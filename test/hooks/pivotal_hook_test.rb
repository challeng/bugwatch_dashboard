require 'rack_test_helper'
require 'unit/support/pivotal_xml'

class PivotalHookTest < Test::Unit::TestCase
  include RackTest

  test "POST /pivotal parses xml and passes to pivotal service" do
    story_id = "123"
    project_id = "999"
    event_type = "story_update"
    story_type = "bug"
    current_state = "finished"
    params = {id: story_id, project_id: project_id, event_type: event_type,
            story_type: story_type, current_state: current_state}
    pivotal_xml = PivotalXml.story params
    PivotalService.expects(:activity).with(params)
    post "/pivotal", {:body => pivotal_xml}
  end

  test "POST /pivotal logs exceptions" do
    PivotalService.stubs(:activity).with(anything).raises(Exception)
    Rails.logger.expects(:error).with(anything)
    post "/pivotal", {:body => ""}
  end

end