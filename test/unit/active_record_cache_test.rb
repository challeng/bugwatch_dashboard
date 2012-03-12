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

  test "#cache_exists? returns false if no commits exist" do
    commit.update_attribute(:repo, nil)
    assert_false sut.cache_exists?
  end

  test "#cache_exists? returns true if commits exist on repo" do
    assert_true sut.cache_exists?
  end

  test "#retrieve returns all bug fixes for commit" do
    Bugwatch::BugFix.expects(:new).with(:date => bug_fix.date_fixed, :file => bug_fix.file, :klass => bug_fix.klass,
                                        :function => bug_fix.function, :sha => commit.sha).returns(:bugwatch_bugfix)
    commit.bug_fixes << bug_fix
    assert_equal [:bugwatch_bugfix], sut.retrieve
  end

end