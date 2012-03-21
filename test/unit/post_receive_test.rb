require 'test_helper'
require 'post_receive'

class PostReceiveTest < ActiveSupport::TestCase

  def rev_list(new_rev)
    "git rev-list --first-parent #{new_rev}"
  end

  def master_ref
    "refs/heads/master"
  end

  def setup
    Dir.stubs(:pwd).returns("/path/to/repo/test_repo.git/hooks")
  end

  test "#payload returns payload with single commit" do
    input = "AAA XXX #{master_ref}"
    Kernel.expects(:system).with(rev_list("XXX")).returns(%w(XXX AAA).join("\n"))
    assert_equal [{:id => "XXX"}], PostReceive.payload(input)[:commits]
  end

  test "#payload returns payload with multiple commits" do
    input = "AAA YYY #{master_ref}"
    Kernel.expects(:system).with(rev_list("YYY")).returns(%w(YYY XXX AAA).join("\n"))
    assert_equal [{:id => "XXX"}, {:id => "YYY"}], PostReceive.payload(input)[:commits]
  end

  test "#payload returns payload with all revisions if old revision is all zeros" do
    input = "0000000000000000000000000000000000000000 YYY #{master_ref}"
    Kernel.expects(:system).with(rev_list("YYY")).returns(%w(YYY XXX).join("\n"))
    assert_equal [{:id => "XXX"}, {:id => "YYY"}], PostReceive.payload(input)[:commits]
  end

  test "#payload returns ref" do
    input = "AAA YYY #{master_ref}"
    Kernel.stubs(:system).returns([])
    assert_equal master_ref, PostReceive.payload(input)[:ref]
  end

  test "#payload returns repo url and name" do
    input = "AAA YYY #{master_ref}"
    Kernel.stubs(:system).returns([])
    expected = {:name => "test_repo", :url => "git:test_repo.git"}
    assert_equal expected, PostReceive.payload(input)[:repository]
  end

end