require 'rack_test_helper'

class ZendeskHookTest < Test::Unit::TestCase
  include RackTest

  test "GET /zendesk enqueues zendesk defect worker" do
    priority = "Urgent"
    title = "Cannot create something"
    ticket_id = "12345"
    status = "Urgent"
    secret = "bugwatch"
    params = {priority: priority, subject: title, id: ticket_id, status: status, secret: secret}
    Resque.expects(:enqueue).with(ZendeskDefectWorker, params)
    get '/zendesk', params
  end

  test "GET /zendesk logs exception" do
    Resque.expects(:enqueue).raises(Exception)
    Rails.logger.expects(:error)
    get '/zendesk', {}
    assert_equal last_response.body, "OK"
  end

end