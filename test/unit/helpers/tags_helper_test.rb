require 'test_helper'

class TagsHelperTest < ActionView::TestCase

  attr_reader :tag, :tag2, :tag3

  def setup
    @tag = stub("Grit::Tag", :tag_date => Time.new(2010, 10, 10))
    @tag2 = stub("Grit::Tag", :tag_date => Time.new(2010, 10, 9))
    @tag3 = stub("Grit::Tag", :tag_date => Time.new(2010, 10, 8))
  end

  test "#tags_by_date sorts tags newest to oldest" do
    assert_equal [tag, tag2, tag3], tags_by_date([tag2, tag3, tag])
  end

  test "#tags_by_date ignores tags that complain about being a directory" do
    tag2.expects(:tag_date).raises Errno::EISDIR
    assert_equal [tag, tag3], tags_by_date([tag, tag2, tag3])
  end

end
