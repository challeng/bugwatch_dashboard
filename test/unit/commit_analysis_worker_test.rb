require 'test_helper'
require 'commit_analysis_worker'

class CommitAnalysisWorkerTest < ActiveSupport::TestCase
  attr_reader :sut, :repo_name, :repo_url

  def setup
    @sut = CommitAnalysisWorker
    @repo_name = "test_repo"
    @repo_url = "path/to/repo"
    @commit = commits(:test_commit)
    Repo.expects(:find_or_create_by_name_and_url).with(repo_name, repo_url).
        returns(repo)
    repo.stubs(:git_fix_cache).returns(git_fix_cache)
    grit_repo.stubs(:commit).with(commit.sha).returns(grit_commit)
    git_fix_cache.stubs(:alerts).returns([])
    git_fix_cache.stubs(:update_repo)
    git_fix_cache.stubs(:repo).returns(grit_repo)
    git_fix_cache.stubs(:cache).returns(Bugwatch::FixCache.new(10))
    grit_commit.stubs(:extend).with(CommitFu::FlogCommit)
  end

  def repo
    repos(:test_repo)
  end

  def git_fix_cache
    @git_fix_cache ||= Bugwatch::GitFixCache.new(repo.name, repo.url)
  end

  def grit_repo
    @grit_repo ||= stub("Grit::Repo")
  end

  def user
    users(:test_user)
  end

  def grit_commit
    @grit_commit ||= stub(:committer => stub(:name => user.name, :email => user.email), :short_message => "test",
                          :sha => commit.sha, :total_score => 5.0, :committed_date => '2010-10-10', :parents => [1])
  end

  def subscription
    subscriptions(:test_subscription)
  end

  def commit
    commits(:test_commit)
  end

  test "#perform adds commit to fix cache" do
    git_fix_cache.expects(:add).with(commit.sha)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform creates user for each commit author" do
    User.expects(:find_or_create_by_email).with(:email => user.email, :name => user.name).returns(user)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform associates commit with user" do
    User.stubs(:find_or_create_by_email).with(:email => user.email, :name => user.name).returns(user)
    Commit.expects(:find_or_create_by_sha_and_repo_id).with(commit.sha, repo.id, has_entry(:user => user)).returns(commit)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform subscribes user to repository" do
    User.stubs(:find_or_create_by_email).returns(user)
    Subscription.expects(:find_or_create_by_repo_id_and_user_id).with(repo.id, user.id)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform creates commit with complexity score" do
    grit_commit.expects(:extend).with(CommitFu::FlogCommit)
    grit_commit.expects(:average).returns(5.0)
    Commit.expects(:find_or_create_by_sha_and_repo_id).with(grit_commit.sha, repo.id, has_entry(:complexity => grit_commit.average)).returns(commit)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform creates bug fixes for commit" do
    Commit.stubs(:find_or_create_by_sha_and_repo_id).returns(commit)
    bugfix = Bugwatch::BugFix.new(:file => "file.rb", :klass => "Test", :function => "method", :date => "2010-10-10")
    Bugwatch::FixCommit.stubs(:new).with(grit_commit).returns(stub('FixCommit', :fixes => [bugfix]))
    BugFix.expects(:find_or_create_by_file_and_klass_and_function_and_commit_id).
        with(bugfix.file, bugfix.klass, bugfix.function, commit.id, :date_fixed => bugfix.date)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform creates commit with committed date as date" do
    Commit.expects(:find_or_create_by_sha_and_repo_id).with(grit_commit.sha, repo.id, has_entry(:date => grit_commit.committed_date)).returns(commit)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  def bug_fix
    @bug_fix ||= Bugwatch::BugFix.new(:file => 'file.rb', :klass => 'Class', :function => 'function')
  end

  def bug_fix2
    @bug_fix2 ||= Bugwatch::BugFix.new(:file => 'file2.rb', :klass => 'Test', :function => 'function')
  end

  def alert
    @alert ||= Alert.new(:commit => commit).tap{|a| a.stubs(:id).returns(1) }
  end

  def alert2
    @alert2 ||= Alert.new(:commit => commit).tap{|a| a.stubs(:id).returns(2) }
  end

  test "#perform creates alert for each alerted bug fix" do
    git_fix_cache.expects(:alerts).with(commit.sha).returns([bug_fix, bug_fix2])
    Alert.expects(:create).with(:commit => commit, :file => 'file.rb', :klass => 'Class', :function => 'function').returns(alert)
    Alert.expects(:create).with(:commit => commit, :file => 'file2.rb', :klass => 'Test', :function => 'function').returns(alert2)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform delivers alerts if not users first alert" do
    subscription.update_attribute(:notify_on_analysis, true)
    mailer = stub
    git_fix_cache.expects(:alerts).with(commit.sha).returns([bug_fix, bug_fix2])
    Alert.stubs(:create).with(:commit => commit, :file => 'file.rb', :klass => 'Class', :function => 'function').returns(alert)
    Alert.stubs(:create).with(:commit => commit, :file => 'file2.rb', :klass => 'Test', :function => 'function').returns(alert2)
    NotificationMailer.expects(:alert).with([alert, alert2], user).returns(mailer)
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

  test "#perform delivers welcome email instead of alert email if first alert" do
    user.alerts.each &:destroy
    Alert.stubs(:create).returns(alert)
    mailer = stub
    git_fix_cache.expects(:alerts).with(commit.sha).returns([bug_fix])
    NotificationMailer.expects(:welcome).with([alert], user).returns(mailer)
    mailer.expects(:deliver)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform does not deliver welcome email if not first alert" do
    git_fix_cache.expects(:alerts).with(commit.sha).returns([bug_fix])
    NotificationMailer.expects(:welcome).never
    sut.perform(repo_name, repo_url, commit.sha)
  end

end