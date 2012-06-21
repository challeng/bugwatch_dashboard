require 'test_helper'
require 'support/zendesk_json'

class ZendeskServiceTest < ActiveSupport::TestCase

  attr_reader :ticket_id, :priority, :title, :status, :secret, :sut

  def setup
    @ticket_id = "1"
    @priority = "High"
    @title = "test"
    @status = "New"
    @secret = "repo_identifier"
    @sut = ZendeskService
    AppConfig.stubs(:zendesk).returns({repo.name => {"secret" => secret}})
  end

  def repo
    @repo ||= repos(:test_repo)
  end

  def get_activity(opts={})
    {"id" => (opts["id"] || ticket_id), "priority" => (opts["priority"] || priority), "subject" => (opts["title"] || title),
     "status" => (opts["status"] || status), "secret" => (opts["secret"] || secret)}
  end

  test ".activity creates new open zendesk defect for new issues" do
    ZendeskDefect.expects(:find_or_create_by_ticket_id_and_repo_id).
        with(ticket_id, repo.id, priority: priority, title: title, status: ZendeskDefect::OPEN)
    sut.activity(get_activity)
  end

  test ".activity creates new open zendesk defect for open issues" do
    ZendeskDefect.expects(:find_or_create_by_ticket_id_and_repo_id).
            with(ticket_id, repo.id, priority: priority, title: title, status: ZendeskDefect::OPEN)
    sut.activity(get_activity("status" => "Open"))
  end

  test ".activity creates new open zendesk defect for pending issues" do
    ZendeskDefect.expects(:find_or_create_by_ticket_id_and_repo_id).
            with(ticket_id, repo.id, priority: priority, title: title, status: ZendeskDefect::OPEN)
    sut.activity(get_activity("status" => "Pending"))
  end

  test ".activity creates new closed zendesk defect for solved issues" do
    ZendeskDefect.expects(:find_or_create_by_ticket_id_and_repo_id).
            with(ticket_id, repo.id, priority: priority, title: title, status: ZendeskDefect::CLOSED)
    sut.activity(get_activity("status" => "Solved"))
  end

  test ".activity resolves existing ticket" do
    defect = ZendeskDefect.create! ticket_id: ticket_id, priority: priority, status: ZendeskDefect::OPEN, :repo => repo
    sut.activity(get_activity("status" => "Solved"))
    assert_equal ZendeskDefect::CLOSED, defect.reload.status
  end

  test ".activity does not create zendesk defect if zendesk not configured for repo" do
    AppConfig.unstub(:zendesk)
    AppConfig.stubs(:zendesk).returns({repo.name => {"secret" => "secret_doesnt_exist" }})
    ZendeskDefect.expects(:create!).never
    sut.activity(get_activity)
  end

  test ".activity does not create zendesk defect if repo for secret not found" do
    AppConfig.unstub(:zendesk)
    AppConfig.stubs(:zendesk).returns({"repo_doesnt_exist" => {"secret" => secret}})
    ZendeskDefect.expects(:create!).never
    sut.activity(get_activity)
  end

  test ".import gets tickets from api" do
    username = "username"
    token = "token"
    organization = "test"
    AppConfig.stubs(:zendesk).returns({repo.name => {"secret" => secret, "username" => username, "token" => token,
                                                     "organization" => organization}})
    ZendeskApi.expects(:tickets).with(username, token, organization).returns("{}")
    sut.import(secret)
  end

  test ".import finds or creates defect for problem tickets" do
    status = "open"
    ZendeskApi.expects(:tickets).returns(ZendeskJson.tickets(subject: title, id: ticket_id, status: status, priority: priority))
    sut.expects(:resolve_status).with(status).returns(ZendeskDefect::OPEN)
    ZendeskDefect.expects(:find_or_create_by_ticket_id_and_repo_id).
        with(ticket_id.to_i, repo.id, title: title, status: ZendeskDefect::OPEN, priority: priority)
    sut.import(secret)
  end

  test ".import ignores creating defects for non problem tickets" do
    ZendeskApi.expects(:tickets).returns(ZendeskJson.tickets(type: "feature"))
    ZendeskDefect.expects(:find_or_create_by_ticket_id_and_repo_id).never
    sut.import(secret)
  end

  test ".import does not call api if repo not configured" do
    AppConfig.stubs(:zendesk).returns({repo.name => {"secret" => "not the right secret"}})
    ZendeskApi.expects(:tickets).never
    sut.import(secret)
  end

  test ".import does not call api if repo not found" do
    AppConfig.stubs(:zendesk).returns({"not the right repo name" => {"secret" => secret}})
    ZendeskApi.expects(:tickets).never
    sut.import(secret)
  end

end