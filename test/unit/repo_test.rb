require 'test_helper'

class RepoTest < ActiveSupport::TestCase

  def sut
    @sut ||= Repo.new(:name => "test_repo", :url => "/path/to/repo")
  end

  def test_clone_repo_clones_repo_url
    Kernel.expects(:system).with("mkdir repos; cd repos; git clone #{sut.url}")
    sut.save
  end

  def test_updates_and_returns_grit_repo_in_repo
    Kernel.expects(:system).with("cd repos/#{sut.name}; git pull origin master")
    grit_repository = stub("Grit::Repo  ")
    Grit::Repo.expects(:new).with("repos/#{sut.name}").returns(grit_repository)
    assert_equal grit_repository, sut.repo
  end

end
