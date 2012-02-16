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
    git_fix_cache = stub
    Bugwatch::GitFixCache.expects(:new).with(sut.name, sut.url).returns(git_fix_cache)
    assert_equal git_fix_cache, sut.git_fix_cache
  end

end
