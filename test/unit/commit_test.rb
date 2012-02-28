require 'test_helper'
require 'active_record_cache'

class CommitTest < ActiveSupport::TestCase

  attr_reader :subscription

  def repo
    @repo ||= Repo.new(:name => "test_repo", :url => "path/to/url").tap {|r| r.stubs(:clone_repo)}
  end

  def sut
    @sut ||= Commit.new(:sha => "XXX", :repo => repo, :user => user)
  end

  def git_fix_cache
    @git_fix_cache ||= Bugwatch::GitFixCache.new(repo.name, repo.url)
  end

  def grit_repo
    @grit_repo ||= stub
  end

  def user
    @user ||= User.new(:email => "email@address", :name => "user name")
  end

  def commit
    @commit ||= stub(:committer => stub(:name => user.name, :email => user.email), :short_message => "test")
  end

  def setup
    repo.stubs(:git_fix_cache).returns(git_fix_cache)
    grit_repo.stubs(:commit).with(sut.sha).returns(commit)
    git_fix_cache.stubs(:write_bug_cache)
    git_fix_cache.stubs(:alerts).returns([])
    git_fix_cache.stubs(:repo).returns(grit_repo)
    git_fix_cache.stubs(:cache).returns(Bugwatch::FixCache.new(10))
    @subscription = Subscription.create!(:repo => repo, :user => user, :notify_on_analysis => true)
  end

  test "after_create sets cache strategy to active record cache" do
    cache_strategy = ActiveRecordCache.new(sut)
    ActiveRecordCache.expects(:new).with(sut).returns(cache_strategy)
    sut.save
    assert_equal cache_strategy, git_fix_cache.caching_strategy
  end

  test "after_create adds commit to fix cache" do
    git_fix_cache.expects(:add).with(sut.sha)
    sut.save
  end      

  test "after_create writes bug cache" do
    git_fix_cache.expects(:write_bug_cache)
    sut.save
  end

  test "after_create creates user for each commit author" do
    User.expects(:find_or_create_by_email).with(:email => user.email, :name => user.name).returns(user)
    sut.save
  end

  test "after_create associates commit with user" do
    User.stubs(:find_or_create_by_email).with(:email => user.email, :name => user.name).returns(user)
    sut.expects(:update_attribute).with(:user, user)
    sut.save
  end

  test "after_create subscribes user to repository" do
    user.id, repo.id = 5, 3
    User.stubs(:find_or_create_by_email).returns(user)
    Subscription.expects(:find_or_create_by_repo_id_and_user_id).with(repo.id, user.id)
    sut.save
  end

  def bug_fix
    @bug_fix ||= Bugwatch::BugFix.new(:file => 'file.rb', :klass => 'Class', :function => 'function')
  end

  def bug_fix2
    @bug_fix2 ||= Bugwatch::BugFix.new(:file => 'file2.rb', :klass => 'Test', :function => 'function')
  end

  test "after_create creates alert for each alerted bug fix" do
    alert1, alert2 = Alert.new, Alert.new
    git_fix_cache.expects(:alerts).with(sut.sha).returns([bug_fix, bug_fix2])
    Alert.expects(:create).with(:commit => sut, :file => 'file.rb', :klass => 'Class', :function => 'function').returns(alert1)
    Alert.expects(:create).with(:commit => sut, :file => 'file2.rb', :klass => 'Test', :function => 'function').returns(alert2)
    sut.save
  end

  test "after_create delivers alerts" do
    alert1, alert2 = Alert.new, Alert.new
    mailer = stub
    git_fix_cache.expects(:alerts).with(sut.sha).returns([bug_fix, bug_fix2])
    Alert.stubs(:create).with(:commit => sut, :file => 'file.rb', :klass => 'Class', :function => 'function').returns(alert1)
    Alert.stubs(:create).with(:commit => sut, :file => 'file2.rb', :klass => 'Test', :function => 'function').returns(alert2)
    NotificationMailer.expects(:alert).with([alert1, alert2], :to => sut.user.email).returns(mailer)
    mailer.expects(:deliver)
    sut.save
  end

  test "after_create does not deliver if no alerts" do
    git_fix_cache.expects(:alerts).with(sut.sha).returns([])
    NotificationMailer.expects(:alert).never
    sut.save
  end

  test "after_create does not deliver if user notification disabled" do
    subscription.update_attribute(:notify_on_analysis, false)
    git_fix_cache.expects(:alerts).with(sut.sha).returns([bug_fix])
    NotificationMailer.expects(:alert).never
    sut.save
  end

end
