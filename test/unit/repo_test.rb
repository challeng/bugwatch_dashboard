require 'test_helper'

class RepoTest < ActiveSupport::TestCase

  def sut
    @sut ||= Repo.new(:name => "test_repo", :url => "/path/to/repo")
  end

  test "after_create clone repo" do
    Kernel.expects(:system).with("mkdir repos; cd repos; git clone #{sut.url}")
    sut.save
  end

  test "#repo updates and returns grit repo" do
    Kernel.expects(:system).with("cd repos/#{sut.name}; git pull origin master")
    grit_repository = stub("Grit::Repo  ")
    Grit::Repo.expects(:new).with("repos/#{sut.name}").returns(grit_repository)
    assert_equal grit_repository, sut.repo
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
