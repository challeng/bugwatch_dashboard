require 'test_helper'

class ReleaseTest < ActiveSupport::TestCase

  attr_reader :project_id

  def setup
    @project_id = "1234"
  end

  test ".update! finds or creates release by deploy date and repo" do
    deploy_sha = "sha"
    deploy_date = "2010-10-10"
    deploy_env = "production"
    repo = repos(:test_repo)
    ExceptionSourceConfig.expects(:repo_name_and_config_by_project_id).with(project_id).returns([repo.name, {}])
    ExceptionSource.expects(:deploys).with(project_id).returns([{sha: deploy_sha, date: deploy_date, env: deploy_env}])
    Release.expects(:find_or_create_by_deploy_date_and_repo_id).with(deploy_date, repo.id, sha: deploy_sha, env: deploy_env)
    Release.update!(project_id)
  end

  test ".update! does not update releases if repo not found" do
    ExceptionSourceConfig.expects(:repo_name_and_config_by_project_id).with(project_id).returns(["not repo name", {}])
    ExceptionSource.expects(:deploys).never
    Release.update!(project_id)
  end

end
