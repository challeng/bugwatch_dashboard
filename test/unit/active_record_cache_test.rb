require 'test_helper'
require 'active_record_cache'

class ActiveRecordCacheTests < ActiveSupport::TestCase

  def sut
    @sut ||= ActiveRecordCache.new(commit)
  end

  def commit
    @commit ||= Commit.new(:sha => "XXX").tap {|c| c.stubs(:analyze)}
  end

  def bug_fix
    @bug_fix ||= BugFix.new(:file => "file.rb")
  end

  test "#cache_exists? returns false if no bug fixes exist" do
    assert_false sut.cache_exists?
  end

  test "#cache_exists? returns true if bug fixes exist on commit" do
    commit.bug_fixes << bug_fix
    assert_true sut.cache_exists?
  end

  test "#retrieve returns all bug fixes for commit" do
    commit.bug_fixes << bug_fix
    assert_equal [bug_fix], sut.retrieve
  end

  test "#store creates BugFix for each bugwatch bug fix" do
    bug_fix = Bugwatch::BugFix.new(:file => "file.rb")
    bug_fix2 = Bugwatch::BugFix.new(:file => "file2.rb")
    BugFix.expects(:create).with(:file => "file.rb", :function => nil, :klass => nil, :commit => commit)
    BugFix.expects(:create).with(:file => "file2.rb", :function => nil, :klass => nil, :commit => commit)
    sut.store([bug_fix, bug_fix2])
  end

  test "#store skips creating BugFix if it already exists" do
    bug_fix = Bugwatch::BugFix.new(:sha => "XXX", :file => "file.rb")
    Commit.stubs(:all).returns([commit])
    BugFix.expects(:create).with(:file => "file.rb", :function => nil, :klass => nil, :commit => commit).never
    sut.store([bug_fix])
  end

end