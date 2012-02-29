require 'test_helper'
require 'active_record_cache'

class ActiveRecordCacheTests < ActiveSupport::TestCase

  def sut
    @sut ||= ActiveRecordCache.new(repo)
  end

  def commit
    commits(:test_commit)
  end

  def bug_fix
    @bug_fix ||= BugFix.new(:file => "file.rb", :date_fixed => '2010-10-10', :klass => "Test",
                            :function => "something", :commit => commit)
  end

  def repo
    repos(:test_repo)
  end

  test "#cache_exists? returns false if no bug fixes exist" do
    assert_false sut.cache_exists?
  end

  test "#cache_exists? returns true if bug fixes exist on commit" do
    commit.bug_fixes << bug_fix
    assert_true sut.cache_exists?
  end

  test "#retrieve returns all bug fixes for commit" do
    Bugwatch::BugFix.expects(:new).with(:date => bug_fix.date_fixed, :file => bug_fix.file, :klass => bug_fix.klass,
                                        :function => bug_fix.function, :sha => commit.sha).returns(:bugwatch_bugfix)
    commit.bug_fixes << bug_fix
    assert_equal [:bugwatch_bugfix], sut.retrieve
  end

  test "#store creates BugFix for each bugwatch bug fix" do
    bug_fix = Bugwatch::BugFix.new(:file => "file.rb", :date => '2010-10-10', :sha => commit.sha)
    bug_fix2 = Bugwatch::BugFix.new(:file => "file2.rb", :date => '2010-11-20', :sha => commit.sha)
    BugFix.expects(:create).with(:file => "file.rb", :function => nil, :klass => nil, :commit => commit, :date_fixed => bug_fix.date)
    BugFix.expects(:create).with(:file => "file2.rb", :function => nil, :klass => nil, :commit => commit, :date_fixed => bug_fix2.date)
    sut.store([bug_fix, bug_fix2])
  end

  test "#store skips creating BugFix if it already exists" do
    bug_fix_params = {:commit => commit, :file => "file.rb", :klass => nil, :function => nil}
    BugFix.create!(bug_fix_params)
    bug_fix = Bugwatch::BugFix.new(bug_fix_params.merge(:sha => commit.sha))
    BugFix.expects(:create).with(bug_fix_params).never
    sut.store([bug_fix])
  end

end