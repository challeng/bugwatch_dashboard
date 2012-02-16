require 'test_helper'
require 'active_record_cache'

class CommitTest < ActiveSupport::TestCase

  def repo
    @repo ||= Repo.new(:name => "test_repo", :url => "path/to/url").tap {|r| r.stubs(:clone_repo)}
  end

  def commit
    @commit ||= Commit.new(:sha => "XXX", :repo => repo)
  end

  def git_fix_cache
    @git_fix_cache ||= Bugwatch::GitFixCache.new(repo.name, repo.url)
  end

  def setup
    repo.stubs(:git_fix_cache).returns(git_fix_cache)
    git_fix_cache.stubs(:add)
    git_fix_cache.stubs(:write_bug_cache)
  end

  test "after_create sets cache strategy to active record cache" do
    cache_strategy = ActiveRecordCache.new(commit)
    ActiveRecordCache.expects(:new).with(commit).returns(cache_strategy)
    commit.save
    assert_equal cache_strategy, git_fix_cache.caching_strategy
  end

  test "after_create adds commit to fix cache" do
    git_fix_cache.expects(:add).with(commit.sha)
    commit.save
  end      

  test "after_create writes bug cache" do
    git_fix_cache.expects(:write_bug_cache)
    commit.save
  end

end
