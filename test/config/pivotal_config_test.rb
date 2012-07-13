require 'fast_test_helper'
require 'config/pivotal_config'

class PivotalConfigTest < Test::Unit::TestCase

  test ".repo_name_and_token_by_project_id returns repo name and token" do
    sut = PivotalConfig
    project_id = 123
    repo_name = "test"
    token = "secret"
    AppConfig.stubs(:pivotal).returns({repo_name => [{"token" => token, "id" => project_id}]})
    result = sut.repo_name_and_token_by_project_id(project_id)
    assert_equal [repo_name, token], result
  end

end