require 'test_helper'

class RepoTest < ActiveSupport::TestCase

  def sut
    @sut ||= Repo.new(:name => "test_repo", :url => "/path/to/repo")
  end

  test "#git_fix_cache creates GitFixCache with name and url" do
    git_fix_cache = Bugwatch::GitFixCache.new(sut.name, sut.url)
    Bugwatch::GitFixCache.expects(:new).with(sut.name, sut.url).returns(git_fix_cache)
    assert_equal git_fix_cache, sut.git_fix_cache
  end

  test "#git_fix_cache sets cache strategy to active record cache" do
    cache_strategy = ActiveRecordCache.new(sut)
    ActiveRecordCache.expects(:new).with(sut).returns(cache_strategy)
    assert_equal cache_strategy, sut.git_fix_cache.caching_strategy
  end

end
