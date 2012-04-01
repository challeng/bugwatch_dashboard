require 'test_helper'
require 'commit_analysis_worker'

class CommitAnalysisWorkerTest < ActiveSupport::TestCase

  def repo
    repos(:test_repo)
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
    @commit ||= commits(:test_commit)
  end

  attr_reader :sut, :repo_name, :repo_url, :git_analyzer, :fix_cache_analyzer

  def setup
    @sut = CommitAnalysisWorker
    @repo_name = "test_repo"
    @repo_url = "path/to/repo"
    @git_analyzer = Bugwatch::GitAnalyzer.new(repo.name, repo.url)
    @fix_cache_analyzer = Bugwatch::FixCacheAnalyzer.new(grit_repo, [])

    ActiveRecordCache.any_instance.stubs(:commit_exists?).returns(false)
    Repo.expects(:find_or_create_by_name_and_url).with(repo_name, repo_url).
        returns(repo)
    Bugwatch::GitAnalyzer.expects(:new).with(repo.name, repo.url).returns(git_analyzer)
    Bugwatch::FixCacheAnalyzer.expects(:new).returns(fix_cache_analyzer)
    grit_repo.stubs(:commit).with(commit.sha).returns(grit_commit)
    fix_cache_analyzer.stubs(:alerts).returns([])
    fix_cache_analyzer.stubs(:call)
    git_analyzer.stubs(:update_repo)
    git_analyzer.stubs(:repo).returns(grit_repo)
    grit_commit.stubs(:extend).with(CommitFu::FlogCommit).returns(grit_commit)
  end


  test "#perform adds commit to git analyzer" do
    git_analyzer.expects(:add).with(commit.sha)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform adds fix cache analyzer as on commit callback" do
    sut.perform(repo_name, repo_url, commit.sha)
    assert_true git_analyzer.on_commit.include? fix_cache_analyzer
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
    grit_commit.expects(:total_score).returns(5.0)
    Commit.expects(:find_or_create_by_sha_and_repo_id).with(grit_commit.sha, repo.id, has_entry(:complexity => grit_commit.total_score)).returns(commit)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform creates bug fixes for commit" do
    bugfix = Bugwatch::BugFix.new(:file => "file.rb", :klass => "Test", :function => "method", :date => "2010-10-10")
    Bugwatch::Commit.stubs(:new).with(grit_commit).returns(stub('FixCommit', :sha => commit.sha, :grit => grit_commit, :fixes => [bugfix]))
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
    fix_cache_analyzer.expects(:alerts).with(commit.sha).returns([bug_fix, bug_fix2])
    Alert.expects(:create).with(:commit => commit, :file => 'file.rb', :klass => 'Class', :function => 'function').returns(alert)
    Alert.expects(:create).with(:commit => commit, :file => 'file2.rb', :klass => 'Test', :function => 'function').returns(alert2)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform delivers alerts if not users first alert" do
    subscription.update_attribute(:notify_on_analysis, true)
    mailer = stub
    fix_cache_analyzer.expects(:alerts).with(commit.sha).returns([bug_fix, bug_fix2])
    Alert.stubs(:create).with(:commit => commit, :file => 'file.rb', :klass => 'Class', :function => 'function').returns(alert)
    Alert.stubs(:create).with(:commit => commit, :file => 'file2.rb', :klass => 'Test', :function => 'function').returns(alert2)
    NotificationMailer.expects(:alert).with([alert, alert2], commit).returns(mailer)
    mailer.expects(:deliver)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform does not deliver if no alerts" do
    fix_cache_analyzer.expects(:alerts).with(commit.sha).returns([])
    NotificationMailer.expects(:alert).never
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform does not deliver if user notification disabled" do
    subscription.update_attribute(:notify_on_analysis, false)
    fix_cache_analyzer.expects(:alerts).with(commit.sha).returns([bug_fix])
    NotificationMailer.expects(:alert).never
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform delivers welcome email instead of alert email if first alert" do
    user.alerts.each &:destroy
    Alert.stubs(:create).returns(alert)
    mailer = stub
    fix_cache_analyzer.expects(:alerts).with(commit.sha).returns([bug_fix])
    NotificationMailer.expects(:welcome).with([alert], commit).returns(mailer)
    mailer.expects(:deliver)
    sut.perform(repo_name, repo_url, commit.sha)
  end

  test "#perform does not deliver welcome email if not first alert" do
    fix_cache_analyzer.expects(:alerts).with(commit.sha).returns([bug_fix])
    NotificationMailer.expects(:welcome).never
    sut.perform(repo_name, repo_url, commit.sha)
  end

end