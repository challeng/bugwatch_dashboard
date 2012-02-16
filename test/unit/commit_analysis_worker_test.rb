require File.expand_path('./../../test_helper', __FILE__)
require 'commit_analysis_worker'

class CommitAnalysisWorkerTests < Test::Unit::TestCase
  attr_reader :sut, :repo_name, :repo_url, :commit_sha, :repo, :commit

  def setup
    @sut = CommitAnalysisWorker
    @repo_name = "test_repo"
    @repo_url = "path/to/repo"
    @commit_sha = "XXX"
    @commit = Commit.new(:sha => commit_sha)
  end

  def repo
    @repo ||= Repo.new(:name => repo_name, :url => repo_url)
  end


  def test_finds_or_creates_repo
    Repo.expects(:find_or_create_by_name_and_url).with(repo_name, repo_url).
        returns(repo)
    Commit.stubs(:new).returns(commit)
    sut.perform(repo_name, repo_url, commit_sha)
  end

  def test_creates_commit_for_repo
    Repo.expects(:find_or_create_by_name_and_url).with(repo_name, repo_url).
        returns(repo)
    Commit.expects(:new).with(:sha => commit_sha).returns(commit)
    sut.perform(repo_name, repo_url, commit_sha)
    assert_equal [commit], repo.commits
  end

end