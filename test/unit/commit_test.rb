require 'test_helper'

class CommitTest < ActiveSupport::TestCase

  def grit_commit
    @grit_commit ||= stub("Grit::Commit", :diffs => [stub("Diff", :diff => "diff text")] * 2, :short_message => "commit message")
  end

  def grit_repo
    @grit_repo ||= stub("Grit::Repo", :commit => grit_commit)
  end

  attr_reader :sut, :repo

  def setup
    @repo = repos(:test_repo)
    @sut = Commit.new(:sha => 'XXX', :repo => repo)
    Grit::Repo.stubs(:new).with(repo.path).returns(grit_repo)
    grit_repo.stubs(:commit).with(sut.sha).returns(grit_commit)
  end

  test "#accumulated_commit_scores returns file names and accumulated score" do
    grit_commit.expects(:extend).with(CommitFu::FlogCommit)
    grit_commit.expects(:scores).returns [["file.rb", 1, 3]]
    assert_equal [["file.rb", 2]], sut.accumulated_commit_scores
  end

  test "#accumulated_commit_scores returns 0 for file if before_score is nil" do
    grit_commit.expects(:extend).with(CommitFu::FlogCommit)
    grit_commit.expects(:scores).returns([['file1.rb', nil, 10]])
    assert_equal [['file1.rb', 0.0]], sut.accumulated_commit_scores
  end

  test "#accumulated_commit_scores returns 0 for file if after_score is nil" do
    grit_commit.expects(:extend).with(CommitFu::FlogCommit)
    grit_commit.expects(:scores).returns([['file1.rb', 20, nil]])
    assert_equal [['file1.rb', 0.0]], sut.accumulated_commit_scores
  end

  test "#diffs gets diffs from grit commit" do
    assert_equal ["diff text", "diff text"], sut.diffs
  end

  test "#message returns short_message from grit commit" do
    assert_equal grit_commit.short_message, sut.message
  end

end
