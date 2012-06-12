require 'test_helper'

class PivotalServiceTest < ActiveSupport::TestCase

  PROJECT_ID = "1"

  attr_reader :sut

  def setup
    @sut = PivotalService
  end

  test ".activity creates pivotal defect if event type is create and story is bug" do
    activity_title = "title"
    activity_description = "test"
    ticket_id = "123"
    repo = repos(:test_repo)
    AppConfig.stubs(:pivotal_projects).returns({repo.name => [PROJECT_ID]})
    activity = {"event_type" => "story_create", "description" => activity_description, "story_type" => "bug",
                "project_id" => PROJECT_ID, "id" => ticket_id, "story_name" => activity_title}
    PivotalDefect.expects(:create!).with(title: activity_title, ticket_id: ticket_id, repo: repo)
    sut.activity(activity)
  end

  test ".activity does not create pivotal defect if event type is not create" do
    activity = {"event_type" => "story_update"}
    PivotalDefect.expects(:create!).never
    sut.activity(activity)
  end

  test ".activity does not create pivotal defect if event type is create and story is not bug" do
    activity = {"event_type" => "story_create", "story_type" => "feature"}
    PivotalDefect.expects(:create!).never
    sut.activity(activity)
  end

  test ".activity does not create pivotal defect if project not configured" do
    activity = {"event_type" => "story_create", "story_type" => "bug", "project_id" => "999"}
    AppConfig.stubs(:pivotal_projects).returns({"repo_name" => [PROJECT_ID]})
    PivotalDefect.expects(:create!).never
    sut.activity(activity)
  end

  test ".activity does not create pivotal defect if repo doesnt exist" do
    activity = {"event_type" => "story_create", "story_type" => "bug", "project_id" => PROJECT_ID}
    AppConfig.stubs(:pivotal_projects).returns({"repo_does_not_exist" => [PROJECT_ID]})
    PivotalDefect.expects(:create!).never
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

  test ".resolve_status resolves unscheduled to open" do
    assert_false sut.resolved?("unscheduled")
  end

  test ".resolve_status resolves started to open" do
      assert_false sut.resolved?("started")
  end

  test ".resolve_status resolves finished to closed" do
      assert_true sut.resolved?("finished")
  end

end