require 'test_helper'
require 'active_record_cache'

class CommitTest < ActiveSupport::TestCase

  def repo
    @repo ||= Repo.new(:name => "test_repo", :url => "path/to/url").tap {|r| r.stubs(:clone_repo)}
  end

  def sut
    @sut ||= Commit.new(:sha => "XXX", :repo => repo)
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
    git_fix_cache.stubs(:repo).returns(grit_repo)
    git_fix_cache.stubs(:cache).returns(Bugwatch::FixCache.new(10))
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

  test "after_create subscribes user to repository" do
    user.id, repo.id = 5, 3
    User.stubs(:find_or_create_by_email).returns(user)
    Subscription.expects(:find_or_create_by_repo_id_and_user_id).with(repo.id, user.id)
    sut.save
  end

end
