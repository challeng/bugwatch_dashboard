require 'rack_test_helper'

class ZendeskHookTest < Test::Unit::TestCase
  include RackTest

  test "GET /zendesk creates defect" do
    priority = "Urgent"
    title = "Cannot create something"
    ticket_id = "12345"
    ZendeskDefect.expects(:create!).with(:priority => priority, :title => title, :ticket_id => ticket_id)
    get '/zendesk', {:priority => priority, :title => title, :id => ticket_id}
  end

end