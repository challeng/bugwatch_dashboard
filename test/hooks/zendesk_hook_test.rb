require 'rack_test_helper'

class ZendeskHookTest < Test::Unit::TestCase
  include RackTest

  test "GET /zendesk calls zendesk service" do
    priority = "Urgent"
    title = "Cannot create something"
    ticket_id = "12345"
    status = "Urgent"
    secret = "bugwatch"
    params = {priority: priority, title: title, id: ticket_id, status: status, secret: secret}
    ZendeskService.expects(:activity).with(params)
    get '/zendesk', params
  end

  test "GET /zendesk logs exception" do
    ZendeskService.expects(:activity).raises(Exception)
    Rails.logger.expects(:error)
    get '/zendesk', {}
    assert_equal last_response.body, "OK"
  end

end