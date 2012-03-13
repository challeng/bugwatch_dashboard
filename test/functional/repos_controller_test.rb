require 'test_helper'

class ReposControllerTest < ActionController::TestCase

  def user
    users(:test_user)
  end

  def repo
    repos(:test_repo)
  end

  def subscription
    subscriptions(:test_subscription)
  end

  def commit
    commits(:test_commit)
  end

  def grit_repo
    @grit_repo ||= stub("Grit::Repo", :commit => grit_commit)
  end

  def grit_commit
    @grit_commit ||= stub("Grit::Commit", :scores => [["file.rb", 1, 3]], :extend => self)
  end

  def setup
    logged_in!
    Repo.any_instance.stubs(:git_fix_cache).returns(stub(:cache => Bugwatch::FixCache.new(10)))
    Grit::Repo.stubs(:new).returns(grit_repo)
  end

  test "GET#index retrieves all repos for user" do
    get :index
    assert_equal [repo], assigns(:repos)
  end

  test "GET#show retrieves repo by id" do
    get :show, :id => repo.id
    assert_equal repo, assigns(:repo)
  end

  test "GET#show redirects to index if repo not found" do
    get :show, :id => 123
    assert_redirected_to repos_path
    assert_equal "Repo with ID 123 could not be found", flash[:alert]
  end

  test "GET#show redirects to index if user has not subscribed to repo" do
    subscription.destroy
    get :show, :id => repo.id
    assert_redirected_to repos_path
    assert_equal "Repo with ID #{repo.id} could not be found", flash[:alert]
  end

  test "GET#show assigns subscription @subscription" do
    get :show, :id => repo.id
    assert_equal subscription, assigns[:subscription]
  end

  test "GET#commit retrieves commit by sha for repo" do
    get :commit, :id => repo.id, :sha => commit.sha
    assert_equal commit, assigns(:commit)
  end

  test "GET#commit redirects to repo if commit doesnt belong to repo" do
    commit.update_attribute(:repo, nil)
    get :commit, :id => repo.id, :sha => commit.sha
    assert_redirected_to repo_path(repo.id)
    assert_equal "Commit with sha #{commit.sha} could not be found for #{repo.name}", flash[:alert]
  end

  test "GET#commit assigns accumulated commit scores to @commit_scores" do
    Grit::Repo.expects(:new).with(repo.path).returns(grit_repo)
    grit_repo.expects(:commit).with(commit.sha).returns(grit_commit)
    grit_commit.expects(:extend).with(CommitFu::FlogCommit)
    get :commit, :id => repo.id, :sha => commit.sha
    assert_equal [["file.rb", 2]], assigns(:commit_scores)
  end

end
