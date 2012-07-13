require 'test_helper'

class ZendeskDefectWorkerTest < ActiveSupport::TestCase

  attr_reader :sut, :project_id, :secret, :data, :repo_name

  def setup
    @sut = ZendeskDefectWorker
    @project_id = 123
    @secret = "secret"
    @data = {"secret" => secret}
    @repo_name = "repo_name"
    ExceptionSourceConfig.stubs(:project_id_by_repo_name).with(repo_name).returns(project_id)
    ZendeskConfig.stubs(:repo_config_by_secret).with(secret).returns([repo_name, {}])
  end

  test ".perform updates releases for repo" do
    ZendeskService.stubs(:activity)
    Release.expects(:update!).with(project_id)
    sut.perform(secret, data)
  end

  test ".perform calls activity for zendesk service" do
    Release.stubs(:update!)
    ZendeskService.expects(:activity).with(data)
    sut.perform(secret, data)
  end

end