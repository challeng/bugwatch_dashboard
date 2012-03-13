require 'test_helper'

class RepoPresenterTest < ActiveSupport::TestCase

  def repo
    repos(:test_repo)
  end

  def sut
    @sut ||= RepoPresenter.new(repo)
  end

  test "takes repo as argument" do
    assert_equal repo, sut.repo
  end

  test "#commit_count calls count on commits" do
    assert_equal repo.commits.count, sut.commit_count
  end

  test "#cache_count gets count of files in fixcache" do
    git_fix_cache = stub(:cache => stub(:cache => {"file1.rb" => [], "file2.rb" => []}))
    repo.stubs(:git_fix_cache).returns(git_fix_cache)
    assert_equal 2, sut.cache_count
  end

  test "#last_updated retrieves last commit by id and returns updated_at" do
    commit = repo.commits.last
    assert_equal commit.updated_at, sut.last_updated
  end

end