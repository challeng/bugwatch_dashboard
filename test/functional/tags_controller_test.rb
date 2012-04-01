require 'test_helper'

class TagsControllerTest < ActionController::TestCase

  attr_reader :grit_repo, :repo

  def setup
    logged_in!
    @grit_repo = stub("Grit::Repo", :tags => [])
    @repo = repos(:test_repo)
    Repo.any_instance.expects(:grit).at_least_once.returns(grit_repo)
  end

  def tag
    grit_commit = stub("Grit::Commit", :committed_date => DateTime.new(2000, 10, 10), :authored_date => DateTime.new(2000, 10, 10))
    @tag ||= stub("Grit::Tag", :name => "tag1", :commit => grit_commit, :tag_date => Time.new)
  end

  def tag2
    grit_commit2 = stub("Grit::Commit", :committed_date => DateTime.new(2000, 10, 12))
    @tag2 ||= stub("Grit::Tag", :name => "tag2", :commit => grit_commit2, :tag_date => Time.new)
  end

  test "GET#index gets all tags for repo" do
    tags = [tag]
    grit_repo.stubs(:tags).returns(tags)
    get :index, :repo_id => repo.id
    assert_equal tags, assigns(:tags)
  end

  test "GET#show gets tag by name" do
    tag = stub("Grit::Tag", :name => "tag1")
    tag2 = stub("Grit::Tag", :name => "tag2")
    grit_repo.stubs(:tags).returns([tag, tag2])
    get :show, :repo_id => repo.id, :id => "tag2"
    assert_equal tag2, assigns(:tag)
  end

  test "GET#diff gets tag_a and tag_b and commits between them" do
    tag3 = stub("Grit::Tag3", :name => "tag3", :commit => stub(:committed_date => Date.today))
    grit_repo.stubs(:tags).returns([tag, tag2, tag3])
    get :diff, :repo_id => repo.id, :tag_a => "tag1", :tag_b => "tag3", :format => :js
    assert_equal tag, assigns(:tag_a)
    assert_equal tag3, assigns(:tag_b)
  end

  test "GET#diff gets commits between tags" do
    commit = Commit.create!(:sha => "123456", :date => DateTime.new(2000, 10, 11), :complexity => 0.0)
    grit_repo.stubs(:tags).returns([tag, tag2])
    get :diff, :repo_id => repo.id, :tag_a => "tag1", :tag_b => "tag2", :format => :js
    assert_equal [commit], assigns(:commits)
  end

end
