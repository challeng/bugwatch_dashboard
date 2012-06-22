require 'test_helper'
require 'support/pivotal_xml'

class PivotalServiceTest < ActiveSupport::TestCase

  PROJECT_ID = "1"

  attr_reader :sut, :ticket_id, :title, :tracker_token

  def setup
    @sut = PivotalService
    @ticket_id = "123"
    @title = "title"
    @tracker_token = "XXX"
    AppConfig.stubs(:pivotal_projects).returns({repo.name => [{"token" => tracker_token, "id" => PROJECT_ID}]})
  end

  def repo
    @repo ||= repos(:test_repo)
  end

  test ".activity creates pivotal defect if event type is create and story is bug" do
    activity_description = "test"
    current_state = "started"
    sut.stubs(:resolved_status).with(current_state).returns(PivotalDefect::OPEN)
    activity = {"event_type" => "story_create", "description" => activity_description, "story_type" => "bug",
                "project_id" => PROJECT_ID, "id" => ticket_id, "story_name" => title, "current_state" => current_state}
    PivotalDefect.expects(:find_or_create_by_ticket_id_and_repo_id).with(
        ticket_id, repo.id, title: title, :status => PivotalDefect::OPEN)
    sut.activity(activity)
  end

  test ".activity does not create pivotal defect if event type is not create" do
    activity = {"event_type" => "story_update"}
    PivotalDefect.expects(:find_or_create_by_ticket_id_and_repo_id).never
    sut.activity(activity)
  end

  test ".activity does not create pivotal defect if event type is create and story is not bug" do
    activity = {"event_type" => "story_create", "story_type" => "feature"}
    PivotalDefect.expects(:find_or_create_by_ticket_id_and_repo_id).never
    sut.activity(activity)
  end

  test ".activity does not create pivotal defect if project not configured" do
    activity = {"event_type" => "story_create", "story_type" => "bug", "project_id" => "not the right project id"}
    PivotalDefect.expects(:find_or_create_by_ticket_id_and_repo_id).never
    sut.activity(activity)
  end

  test ".activity does not create pivotal defect if repo doesnt exist" do
    activity = {"event_type" => "story_create", "story_type" => "bug", "project_id" => PROJECT_ID}
    AppConfig.stubs(:pivotal_projects).returns({"repo_does_not_exist" => [PROJECT_ID]})
    PivotalDefect.expects(:find_or_create_by_ticket_id_and_repo_id).never
    sut.activity(activity)
  end

  test ".activity resolves defect if event type is update and state is resolved" do
    activity = {"event_type" => "story_update", "story_type" => "bug", "project_id" => PROJECT_ID, "current_state" => "finished", "id" => "123"}
    sut.stubs(:resolved?).returns(true)
    pivotal_defect = PivotalDefect.new
    PivotalDefect.expects(:find_by_ticket_id!).with("123").returns(pivotal_defect)
    pivotal_defect.expects(:resolve!)
    sut.activity(activity)
  end

  test ".activity does not resolve if event type is update and state is not resolved" do
    activity = {"event_type" => "story_update", "story_type" => "bug", "project_id" => PROJECT_ID, "current_state" => "finished", "id" => "123"}
    sut.stubs(:resolved?).returns(false)
    PivotalDefect.expects(:find_by_ticket_id!).never
    sut.activity(activity)
  end

  test ".activity does not resolve if event type is update and ticket not found" do
    activity = {"event_type" => "story_update", "story_type" => "bug", "project_id" => PROJECT_ID, "current_state" => "finished", "id" => "123"}
    sut.stubs(:resolved?).returns(true)
    PivotalDefect.expects(:find_by_ticket_id!).raises(ActiveRecord::RecordNotFound)
    PivotalDefect.any_instance.expects(:resolve!).never
    sut.activity(activity)
  end

  test ".activity archives open defect if event type is delete" do
    defect = defects(:pivotal_open)
    activity = {"event_type" => "story_delete", "story_type" => "bug", "project_id" => PROJECT_ID, "current_state" => "deleted", "id" => defect.ticket_id}
    PivotalDefect.expects(:find_by_ticket_id!).with(defect.ticket_id).returns(defect)
    defect.expects(:archive!)
    sut.activity(activity)
  end

  test ".resolved? resolves unscheduled to open" do
    assert_false sut.resolved?("unscheduled")
  end

  test ".resolved? resolves started to open" do
    assert_false sut.resolved?("started")
  end

  test ".resolved? resolves finished to closed" do
    assert_true sut.resolved?("finished")
  end

  test ".import gets stories from api" do
    PivotalApi.expects(:defects).with(PROJECT_ID, tracker_token).returns(PivotalXml.stories)
    sut.import(PROJECT_ID)
  end

  test ".import finds or creates defect for unresolved story" do
    current_state = "started"
    PivotalApi.stubs(:defects).returns(
        PivotalXml.stories(current_state: current_state, id: ticket_id, name: title, project_id: PROJECT_ID))
    sut.expects(:resolved?).with(current_state).returns(false)
    PivotalDefect.expects(:find_or_create_by_ticket_id_and_repo_id).with(
        ticket_id, repo.id, title: title, status: PivotalDefect::OPEN)
    sut.import(PROJECT_ID)
  end

  test ".import finds or creates defect for resolved story" do
    current_state = "finished"
    PivotalApi.stubs(:defects).returns(
        PivotalXml.stories(current_state: current_state, id: ticket_id, name: title, project_id: PROJECT_ID))
    sut.expects(:resolved?).with(current_state).returns(true)
    PivotalDefect.expects(:find_or_create_by_ticket_id_and_repo_id).with(
        ticket_id, repo.id, title: title, status: PivotalDefect::CLOSED)
    sut.import(PROJECT_ID)
  end

  test ".import does not get stories from api if project not configured" do
    PivotalApi.expects(:defects).never
    sut.import(9999938483)
  end

  test ".import does not get stories from api if project configured but repo not found" do
    AppConfig.stubs(:pivotal_projects).returns({"not the right repo name" => [PROJECT_ID]})
    PivotalApi.expects(:defects).never
    sut.import(PROJECT_ID)
  end

end