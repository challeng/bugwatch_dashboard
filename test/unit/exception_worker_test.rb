require 'test_helper'
require 'exception_worker'

class ExceptionWorkerTest < ActiveSupport::TestCase

  attr_reader :repo_name, :exception_type, :backtrace, :deploy_sha

  def setup
    @repo_name = "repo_name"
    @exception_type = "NoMethodError"
    @backtrace = [["file.rb", 5]]
    @deploy_sha = "AAA"
  end

  test "#perform selects commits using exception tracker" do
    repo = stub(:git_analyzer => stub)
    Repo.expects(:find_by_name!).with(repo_name).returns(repo)
    exception_data = Bugwatch::ExceptionData.new({})
    Bugwatch::ExceptionData.expects(:new).with({:type => exception_type, :backtrace => backtrace}).returns(exception_data)
    deploy_before_last_sha = "ZZZ"
    ExceptionSource.expects(:deploy_before).with(deploy_sha).returns(deploy_before_last_sha)
    Bugwatch::ExceptionTracker.expects(:discover).with(repo.git_analyzer, deploy_sha, exception_data, deploy_before_last_sha)
    ExceptionWorker.perform(repo_name, exception_type, backtrace, deploy_sha)
  end

  test "#perform logs if repo not found" do
    Repo.expects(:find_by_name!).raises(ActiveRecord::RecordNotFound)
    Bugwatch::ExceptionTracker.expects(:discover).never
    Rails.logger.expects(:error)
    ExceptionWorker.perform(repo_name, exception_type, backtrace, deploy_sha)
  end

end