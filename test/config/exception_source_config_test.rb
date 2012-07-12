require 'fast_test_helper'
require 'config/exception_source_config'

class ExceptionSourceConfigTest < Test::Unit::TestCase

  attr_reader :sut, :project_id, :repo_name, :config

  def setup
    @sut = ExceptionSourceConfig
    @project_id = 123
    @repo_name = "repo_name"
    @config = {"id" => project_id}
    AppConfig.stubs(:exceptions).returns({repo_name => config})
  end

  test ".project_id_by_repo_name returns project id" do
    assert_equal project_id, sut.project_id_by_repo_name(repo_name)
  end

  test ".repo_name_and_config_by_project_id returns repo name and config" do
    expected = [repo_name, config]
    assert_equal expected, sut.repo_name_and_config_by_project_id(project_id)
  end

  test ".repo_name_and_config_by_project_id raises exception if project not configured" do
    AppConfig.stubs(:exceptions).returns({repo_name => {"account" => "account_name", "id" => "not the right project"}})
    assert_raises(ExceptionSourceConfig::ExceptionMisconfiguration) { sut.repo_name_and_config_by_project_id(project_id) }
  end

end