require 'test_helper'

class ReleaseTest < ActiveSupport::TestCase

  test ".update! finds or creates release by sha" do
    project_id = "1234"
    deploy_sha = "sha"
    deploy_date = "2010-10-10"
    deploy_env = "production"
    ExceptionSource.expects(:deploys).with(project_id).returns([{sha: deploy_sha, date: deploy_date, env: deploy_env}])
    Release.expects(:find_or_create_by_sha).with(deploy_sha, deploy_date: deploy_date, env: deploy_env)
    Release.update!(project_id)
  end

end
