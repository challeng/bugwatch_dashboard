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
    fix_cache = stub(:cache => {"file1.rb" => [], "file2.rb" => []})
    repo.stubs(:fix_cache).returns(fix_cache)
    assert_equal 2, sut.cache_count
  end

  test "#last_updated retrieves last commit by id and returns updated_at" do
    commit = repo.commits.last
    assert_equal commit.updated_at, sut.last_updated
  end

  test "#total_complexity sums complexity for a repos commits" do
    expected = repo.commits.sum(:complexity)
    assert_equal expected, sut.total_complexity
  end

end