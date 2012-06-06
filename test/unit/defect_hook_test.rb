require 'test_helper'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class DefectHookTests < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    DefectHook
  end

  test "POST /defect creates defect" do
    priority = "Urgent"
    title = "Cannot create something"
    ticket_id = "12345"
    Defect.expects(:create!).with(:priority => priority, :title => title, :ticket_id => ticket_id)
    post '/defect', {:payload => [priority, title, ticket_id].join("|")}
  end

end