require 'test_helper'

class RepoTest < ActiveSupport::TestCase

  def sut
    @sut ||= Repo.new(:name => "test_repo", :url => "https://domain/path/to/repo")
  end

  attr_reader :git_fix_cache

  def setup
    @git_fix_cache = Bugwatch::GitFixCache.new(sut.name, sut.url)
  end

  test "#git_fix_cache creates GitFixCache with name and url" do
    Bugwatch::GitFixCache.expects(:new).with(sut.name, sut.url).returns(git_fix_cache)
    assert_equal git_fix_cache, sut.git_fix_cache
  end

  test "#git_fix_cache sets cache strategy to active record cache" do
    cache_strategy = ActiveRecordCache.new(sut)
    ActiveRecordCache.expects(:new).with(sut).returns(cache_strategy)
    assert_equal cache_strategy, sut.git_fix_cache.caching_strategy
  end

  test "#git_fix_cache creates GitFixCache with protocolized url if rule matches domain" do
    AppConfig.stubs(:git_domains).returns(['domain'])
    Bugwatch::GitFixCache.expects(:new).with(sut.name, "domain:/path/to/repo.git").returns(git_fix_cache)
    sut.git_fix_cache
  end

end
