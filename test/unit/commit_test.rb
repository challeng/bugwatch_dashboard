require 'test_helper'

class CommitTest < ActiveSupport::TestCase

  def repo
    @repo ||= Repo.new(:name => "test_repo", :url => "path/to/url").tap {|r| r.stubs(:clone_repo)}
  end

  def commit
    @commit ||= Commit.new(:sha => "XXX", :repo => repo)
  end

  def test_creates_bug_fix_for_every_bug_fix_in_commit_in_analyze
    grit_repo = stub
    grit_commit = stub
    fix_commit = Bugwatch::FixCommit.new(grit_commit)
    bug_fix = Bugwatch::BugFix.new({:sha => "YYY", :file => "file.rb", :function => 'some_method', :klass => 'Class'})
    bug_fix2 = Bugwatch::BugFix.new({:sha => "ZZZ", :file => "file2.rb", :function => 'random_method', :klass => 'Klass'})
    fix_commit.stubs(:fixes).returns([bug_fix, bug_fix2])
    grit_repo.stubs(:commit).with(commit.sha).returns(grit_commit)
    repo.stubs(:repo).returns(grit_repo)
    Bugwatch::FixCommit.stubs(:new).with(grit_commit).returns(fix_commit)
    BugFix.expects(:create).with(:file => bug_fix.file, :function => bug_fix.function, :klass => bug_fix.klass, :commit => commit)
    BugFix.expects(:create).with(:file => bug_fix2.file, :function => bug_fix2.function, :klass => bug_fix2.klass, :commit => commit)
    commit.save
  end

end
