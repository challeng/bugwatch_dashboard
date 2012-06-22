require 'test_helper'
require 'exception_source'

class ExceptionSourceTest < ActiveSupport::TestCase

  PROJECT_ID = 123
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
    HTTParty.expects(:get).with("http://#{ACCOUNT}.airbrake.io/projects/#{PROJECT_ID}/deploys.xml",
                                :query => {:api_key => API_KEY}).returns(response)
    sut.deploys(PROJECT_ID)
  end

  test ".deploys parses response with nokogiri" do
    sut.expects(:get).returns(DEPLOY_XML)
    doc = Nokogiri::XML DEPLOY_XML
    Nokogiri.expects(:XML).with(DEPLOY_XML).returns(doc)
    sut.deploys(PROJECT_ID)
  end

  test ".deploys raises exception if project not configured" do
    AppConfig.stubs(:exceptions).returns({repo.name => {"account" => ACCOUNT, "id" => "not the right project"}})
    assert_raises(ExceptionSource::ExceptionMisconfiguration) { sut.deploys(PROJECT_ID) }
  end

  test ".deploy_before returns deploy sha after given sha" do
    sut.expects(:get).returns(DEPLOY_XML)
    assert_equal "second_sha", ExceptionSource.deploy_before("sha", PROJECT_ID)
  end

end