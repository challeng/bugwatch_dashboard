require 'test_helper'
require 'exception_source'

class ExceptionSourceTest < ActiveSupport::TestCase

  PROJECT_ID = 1111
  API_KEY = "api"
  ACCOUNT = "test"
  DEPLOY_XML = <<-XML
<projects>
  <deploy>
    <id>123</id>
    <project-id>#{PROJECT_ID}</project-id>
    <rails-env>production</rails-env>
    <created-at>2012-03-15 20:50:44 UTC</created-at>
    <ends-at>2012-06-04 19:59:50 UTC</ends-at>
    <scm-revision>sha</scm-revision>
    <scm-repository>
      git@git.domain.com:user/repository.git
    </scm-repository>
    <local-username>test_user</local-username>
  </deploy>
  <deploy>
    <id>124</id>
    <project-id>#{PROJECT_ID}</project-id>
    <rails-env>production</rails-env>
    <created-at>2012-03-15 20:50:44 UTC</created-at>
    <ends-at>2012-06-04 19:59:50 UTC</ends-at>
    <scm-revision>second_sha</scm-revision>
    <scm-repository>
      git@git.domain.com:user/repository.git
    </scm-repository>
    <local-username>test_user</local-username>
  </deploy>
  <deploy>
    <id>125</id>
    <project-id>#{PROJECT_ID}</project-id>
    <rails-env>production</rails-env>
    <created-at>2012-03-15 20:50:44 UTC</created-at>
    <ends-at>2012-06-04 19:59:50 UTC</ends-at>
    <scm-revision>third_sha</scm-revision>
    <scm-repository>
      git@git.domain.com:user/repository.git
    </scm-repository>
    <local-username>test_user</local-username>
  </deploy>
</projects>
  XML

  def setup
    AppConfig.stubs(:exceptions).returns({"airbrake" => {"account" => ACCOUNT, "api_key" => API_KEY}})
  end

  test ".deploy_before gets deploys from airbrake" do
    HTTParty.expects(:get).with("http://#{ACCOUNT}.airbrake.io/projects/#{PROJECT_ID}/deploys.xml", :query => {:api_key => API_KEY}).returns("")
    ExceptionSource.deploy_before("sha", :project_id => PROJECT_ID)
  end

  test ".deploy_before raises exception if no airbrake configuration" do
    AppConfig.stubs(:exceptions).returns(nil)
    assert_raises(ExceptionSource::ExceptionMisconfiguration) { ExceptionSource.deploy_before("sha") }
  end

  test ".deploy_before returns deploy sha after given sha" do
    HTTParty.expects(:get).returns(DEPLOY_XML)
    assert_equal "second_sha", ExceptionSource.deploy_before("sha")
  end

end