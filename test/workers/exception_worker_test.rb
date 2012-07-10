require 'test_helper'
require 'exception_worker'

class ExceptionWorkerTest < ActiveSupport::TestCase

  attr_reader :repo_name, :exception_type, :backtrace, :deploy_sha, :repo, :deploy_before_last_sha

  def setup
    @repo_name = "repo_name"
    @exception_type = "NoMethodError"
    @backtrace = [["file.rb", 5]]
    @deploy_sha = "AAA"
    @repo = stub("Repo", :git_analyzer => stub("Bugwatch::GitAnalyzer"))
    @deploy_before_last_sha = "ZZZ"
    Repo.expects(:find_by_name!).with(repo_name).returns(repo)
    ExceptionSource.stubs(:deploy_before).with(deploy_sha).returns(deploy_before_last_sha)
  end

  test "#perform selects commits using exception tracker" do
    exception_data = Bugwatch::ExceptionData.new({})
    Bugwatch::ExceptionData.expects(:new).with({:type => exception_type, :backtrace => backtrace}).returns(exception_data)
    Bugwatch::ExceptionTracker.expects(:discover).with(repo.git_analyzer, deploy_sha, exception_data, deploy_before_last_sha).
        returns([])
    ExceptionWorker.perform(repo_name, exception_type, backtrace, deploy_sha)
  end

  test "#perform logs if repo not found" do
    Repo.unstub(:find_by_name!)
    Repo.expects(:find_by_name!).raises(ActiveRecord::RecordNotFound)
    Bugwatch::ExceptionTracker.expects(:discover).never
    Rails.logger.expects(:error)
    ExceptionWorker.perform(repo_name, exception_type, backtrace, deploy_sha)
  end

  test "#perform creates mystery for exception data" do
    pipe_delimited_backtrace = backtrace.map {|(file, line)| "#{file}:#{line}" }.join("|")
    Bugwatch::ExceptionTracker.expects(:discover).returns([])
    Mystery.expects(:create!).with(exception_type: exception_type, backtrace: pipe_delimited_backtrace)
    ExceptionWorker.perform(repo_name, exception_type, backtrace, deploy_sha)
  end

  test "#perform creates clue for each discovered commit" do
    mystery = Mystery.new
    Mystery.expects(:create!).returns(mystery)
    commit, commit2 = stub, stub
    bugwatch_commit1, bugwatch_commit2 = stub("Bugwatch::Commit", :sha => "commit_sha"),
        stub("Bugwatch::Commit", :sha => "second_commit_sha")
    Bugwatch::ExceptionTracker.expects(:discover).returns([bugwatch_commit1, bugwatch_commit2])
    Commit.expects(:find_by_sha!).with("commit_sha").returns(commit)
    Commit.expects(:find_by_sha!).with("second_commit_sha").returns(commit2)
    Clue.expects(:create!).with(commit: commit, mystery: mystery)
    Clue.expects(:create!).with(commit: commit2, mystery: mystery)
    ExceptionWorker.perform(repo_name, exception_type, backtrace, deploy_sha)
  end

end