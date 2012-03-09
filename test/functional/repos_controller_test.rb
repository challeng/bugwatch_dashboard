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

  def setup
    logged_in!
    Repo.any_instance.stubs(:git_fix_cache).returns(stub(:cache => Bugwatch::FixCache.new(10)))
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

end
