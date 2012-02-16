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

  def test_sets_cache_strategy_to_active_record_cache
    cache_strategy = ActiveRecordCache.new(commit)
    ActiveRecordCache.expects(:new).with(commit).returns(cache_strategy)
    commit.save
    assert_equal cache_strategy, git_fix_cache.caching_strategy
  end

  def test_adds_commit_to_fix_cache_after_create
    git_fix_cache.expects(:add).with(commit.sha)
    commit.save
  end

  def test_writes_bug_cache_after_create
    git_fix_cache.expects(:write_bug_cache)
    commit.save
  end

end
