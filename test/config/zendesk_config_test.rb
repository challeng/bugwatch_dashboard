require 'fast_test_helper'
require 'config/zendesk_config'

class ZendeskConfigTest < Test::Unit::TestCase

  test ".repo_config_by_secret returns repo name and config for secret" do
    sut = ZendeskConfig
    repo_secret = "repo_secret"
    config = {"secret" => repo_secret}
    repo_name = "repo_name"
    AppConfig.stubs(:zendesk).returns({repo_name => {"secret" => repo_secret}})
    assert_equal [repo_name, config], sut.repo_config_by_secret(repo_secret)
  end

end