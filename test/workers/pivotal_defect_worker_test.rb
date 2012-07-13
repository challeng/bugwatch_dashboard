require 'test_helper'
require 'workers/pivotal_defect_worker'

class PivotalDefectWorkerTest < Test::Unit::TestCase

  attr_reader :activity_data, :pivotal_project_id, :exception_source_project_id, :sut

  def setup
    @activity_data = {"data" => "test"}
    @pivotal_project_id = 456
    @exception_source_project_id = 123
    @sut = PivotalDefectWorker
    repo_name = "test"
    ExceptionSourceConfig.stubs(:project_id_by_repo_name).with(repo_name).returns(exception_source_project_id)
    PivotalConfig.stubs(:repo_name_and_token_by_project_id).with(pivotal_project_id).returns([repo_name, ""])
  end

  test ".perform updates releases for repo" do
    Release.expects(:update!).with(exception_source_project_id)
    sut.perform(pivotal_project_id, activity_data)
  end

  test ".perform passes activity to pivotal service" do
    Release.stubs(:update!)
    PivotalService.expects(:activity).with(activity_data)
    sut.perform(pivotal_project_id, activity_data)
  end

end