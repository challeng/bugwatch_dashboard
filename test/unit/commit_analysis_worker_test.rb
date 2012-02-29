require 'test_helper'
require 'commit_analysis_worker'

class CommitAnalysisWorkerTest < ActiveSupport::TestCase
  attr_reader :sut, :repo_name, :repo_url, :commit_sha

  def setup
    @sut = CommitAnalysisWorker
    @repo_name = "test_repo"
    @repo_url = "path/to/repo"
    @commit = commits(:test_commit)
    Repo.expects(:find_or_create_by_name_and_url).with(repo_name, repo_url).
        returns(repo)
    repo.stubs(:git_fix_cache).returns(git_fix_cache)
    grit_repo.stubs(:commit).with(commit.sha).returns(grit_commit)
    git_fix_cache.stubs(:write_bug_cache)
    git_fix_cache.stubs(:alerts).returns([])
    git_fix_cache.stubs(:repo).returns(grit_repo)
    git_fix_cache.stubs(:cache).returns(Bugwatch::FixCache.new(10))
  end

  def repo
    repos(:test_repo)
  end

  def git_fix_cache
    @git_fix_cache ||= Bugwatch::GitFixCache.new(repo.name, repo.url)
  end

  def grit_repo
    @grit_repo ||= stub
  end

  def user
    users(:test_user)
  end

  def grit_commit
    @grit_commit ||= stub(:committer => stub(:name => user.name, :email => user.email), :short_message => "test", :sha => commit.sha)
  end

  def subscription
    subscriptions(:test_subscription)
  end

  def commit
    commits(:test_commit)
  end

  test "#perform sets cache strategy to active record cache" do
    cache_strategy = ActiveRecordCache.new(repo)
    ActiveRecordCache.expects(:new).with(repo).returns(cache_strategy)
    sut.perform(repo_name, repo_url, commit.sha)
    assert_equal cache_strategy, git_fix_cache.caching_strategy
  end

  test "#perform adds commit to fix cache" do
    git_fix_cache.expects(:add).with(commit.sha)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform writes bug cache" do
    git_fix_cache.expects(:write_bug_cache)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform creates user for each commit author" do
    User.expects(:find_or_create_by_email).with(:email => user.email, :name => user.name).returns(user)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform associates commit with user" do
    User.stubs(:find_or_create_by_email).with(:email => user.email, :name => user.name).returns(user)
    Commit.expects(:find_or_create_by_sha_and_repo_id).with(commit.sha, repo.id, :user => user).returns(commit)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform subscribes user to repository" do
    User.stubs(:find_or_create_by_email).returns(user)
    Subscription.expects(:find_or_create_by_repo_id_and_user_id).with(repo.id, user.id)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  def bug_fix
    @bug_fix ||= Bugwatch::BugFix.new(:file => 'file.rb', :klass => 'Class', :function => 'function')
  end

  def bug_fix2
    @bug_fix2 ||= Bugwatch::BugFix.new(:file => 'file2.rb', :klass => 'Test', :function => 'function')
  end

  test "#perform creates alert for each alerted bug fix" do
    alert1, alert2 = Alert.new, Alert.new
    git_fix_cache.expects(:alerts).with(commit.sha).returns([bug_fix, bug_fix2])
    Alert.expects(:create).with(:commit => commit, :file => 'file.rb', :klass => 'Class', :function => 'function').returns(alert1)
    Alert.expects(:create).with(:commit => commit, :file => 'file2.rb', :klass => 'Test', :function => 'function').returns(alert2)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform delivers alerts" do
    subscription.update_attribute(:notify_on_analysis, true)
    alert1, alert2 = Alert.new, Alert.new
    mailer = stub
    git_fix_cache.expects(:alerts).with(commit.sha).returns([bug_fix, bug_fix2])
    Alert.stubs(:create).with(:commit => commit, :file => 'file.rb', :klass => 'Class', :function => 'function').returns(alert1)
    Alert.stubs(:create).with(:commit => commit, :file => 'file2.rb', :klass => 'Test', :function => 'function').returns(alert2)
    NotificationMailer.expects(:alert).with([alert1, alert2], user, :to => commit.user.email).returns(mailer)
    mailer.expects(:deliver)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform does not deliver if no alerts" do
    git_fix_cache.expects(:alerts).with(commit.sha).returns([])
    NotificationMailer.expects(:alert).never
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform does not deliver if user notification disabled" do
    subscription.update_attribute(:notify_on_analysis, false)
    git_fix_cache.expects(:alerts).with(commit.sha).returns([bug_fix])
    NotificationMailer.expects(:alert).never
    sut.perform(repo_name, repo_url, commit.sha)
  end


end