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

end