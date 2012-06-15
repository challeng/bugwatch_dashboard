require 'test_helper'

class ZendeskServiceTest < ActiveSupport::TestCase

  attr_reader :ticket_id, :priority, :title, :status, :secret, :sut

  def setup
    @ticket_id = "1"
    @priority = "High"
    @title = "test"
    @status = "New"
    @secret = "repo_identifier"
    @sut = ZendeskService
    AppConfig.stubs(:zendesk).returns({secret => repo.name})
  end

  def repo
    @repo ||= repos(:test_repo)
  end

  def get_activity(opts={})
    {"id" => (opts["id"] || ticket_id), "priority" => (opts["priority"] || priority), "title" => (opts["title"] || title),
     "status" => (opts["status"] || status), "secret" => (opts["secret"] || secret)}
  end

  test ".activity creates new open zendesk defect for new issues" do
    ZendeskDefect.expects(:create!).with(ticket_id: ticket_id, priority: priority, title: title,
                                         status: ZendeskDefect::OPEN, :repo => repo)
    sut.activity(get_activity)
  end

  test ".activity creates new open zendesk defect for open issues" do
    ZendeskDefect.expects(:create!).with(ticket_id: ticket_id, priority: priority, title: title,
                                         status: ZendeskDefect::OPEN, :repo => repo)
    sut.activity(get_activity("status" => "Open"))
  end

  test ".activity creates new open zendesk defect for pending issues" do
    ZendeskDefect.expects(:create!).with(ticket_id: ticket_id, priority: priority, title: title,
                                         status: ZendeskDefect::OPEN, :repo => repo)
    sut.activity(get_activity("status" => "Pending"))
  end

  test ".activity creates new closed zendesk defect for solved issues" do
    ZendeskDefect.expects(:create!).with(ticket_id: ticket_id, priority: priority, title: title,
                                         status: ZendeskDefect::CLOSED, :repo => repo)
    sut.activity(get_activity("status" => "Solved"))
  end

  test ".activity resolves existing ticket" do
    defect = ZendeskDefect.create! ticket_id: ticket_id, priority: priority, status: ZendeskDefect::OPEN, :repo => repo
    sut.activity(get_activity("status" => "Solved"))
    assert_equal ZendeskDefect::CLOSED, defect.reload.status
  end

  test ".activity does not create zendesk defect if zendesk not configured for repo" do
    AppConfig.unstub(:zendesk)
    AppConfig.stubs(:zendesk).returns({"secret_doesnt_exist" => repo.name})
    ZendeskDefect.expects(:create!).never
    sut.activity(get_activity)
  end

  test ".activity does not create zendesk defect if repo for secret not found" do
    AppConfig.unstub(:zendesk)
    AppConfig.stubs(:zendesk).returns({secret => "repo_doesnt_exist"})
    ZendeskDefect.expects(:create!).never
    sut.activity(get_activity)
  end

end