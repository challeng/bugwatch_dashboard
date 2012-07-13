require 'test_helper'
require 'exception_source'

class ExceptionSourceTest < ActiveSupport::TestCase

  PROJECT_ID = "123"
  API_KEY = "api"
  ACCOUNT = "test"
  DEPLOY_DATE = "2012-03-15 20:50:44 UTC"
  DEPLOY_XML = <<-XML
<projects>
  <deploy>
    <id>1</id>
    <project-id>#{PROJECT_ID}</project-id>
    <rails-env>production</rails-env>
    <created-at>#{DEPLOY_DATE}</created-at>
    <ends-at>2012-06-04 19:59:50 UTC</ends-at>
    <scm-revision>sha</scm-revision>
    <scm-repository>
      git@git.domain.com:user/repository.git
    </scm-repository>
    <local-username>test_user</local-username>
  </deploy>
  <deploy>
    <id>2</id>
    <project-id>#{PROJECT_ID}</project-id>
    <rails-env>production</rails-env>
    <created-at>#{DEPLOY_DATE}</created-at>
    <ends-at>2012-06-04 19:59:50 UTC</ends-at>
    <scm-revision>second_sha</scm-revision>
    <scm-repository>
      git@git.domain.com:user/repository.git
    </scm-repository>
    <local-username>test_user</local-username>
  </deploy>
  <deploy>
    <id>3</id>
    <project-id>#{PROJECT_ID}</project-id>
    <rails-env>production</rails-env>
    <created-at>#{DEPLOY_DATE}</created-at>
    <ends-at>2012-06-04 19:59:50 UTC</ends-at>
    <scm-revision>third_sha</scm-revision>
    <scm-repository>
      git@git.domain.com:user/repository.git
    </scm-repository>
    <local-username>test_user</local-username>
  </deploy>
</projects>
  XML

  def repo
    @repo ||= repos(:test_repo)
  end

  attr_reader :sut

  def setup
    @sut = ExceptionSource
    AppConfig.stubs(:exceptions).returns({repo.name => {"account" => ACCOUNT, "api_key" => API_KEY, "id" => PROJECT_ID}})
  end

  test ".deploys gets deploys from airbrake" do
    response = stub
    response.expects(:body).returns("")
    HTTParty.expects(:get).with("https://#{ACCOUNT}.airbrake.io/projects/#{PROJECT_ID}/deploys.xml",
                                :query => {:auth_token => API_KEY}).returns(response)
    sut.deploys(PROJECT_ID)
  end

  test ".deploys returns list of deploy data" do
    sut.expects(:get).returns(DEPLOY_XML)
    first_deploy = {project_id: PROJECT_ID, date: DEPLOY_DATE, sha: "sha", env: "production"}
    second_deploy = {project_id: PROJECT_ID, date: DEPLOY_DATE, sha: "second_sha", env: "production"}
    third_deploy = {project_id: PROJECT_ID, date: DEPLOY_DATE, sha: "third_sha", env: "production"}
    assert_equal [first_deploy, second_deploy, third_deploy], sut.deploys(PROJECT_ID)
  end

  test ".deploy_before returns deploy sha after given sha" do
    sut.expects(:get).returns(DEPLOY_XML)
    assert_equal "second_sha", ExceptionSource.deploy_before("sha", PROJECT_ID)
  end

end