require 'test_helper'

class RepoControllerTest < ActionController::TestCase

  def setup
    logged_in!
  end

  def user
    users(:test_user)
  end

  def repo
    repos(:test_repo)
  end

  test "GET#index retrieves all repos for user" do
    user.subscriptions << Subscription.new(:repo => repo)
    get :index
    assert_equal [repo], assigns(:repos)
  end

  test "GET#show retrieves repo by id" do
    user.subscriptions << Subscription.new(:repo => repo)
    get :show, :id => repo.id
    assert_equal repo, assigns(:repo)
  end

  test "GET#show redirects to index if repo not found" do
    get :show, :id => 123
    assert_redirected_to repo_url
    assert_equal "Repo with ID 123 could not be found", flash[:alert]
  end

  test "GET#show redirects to index if user has not subscribed to repo" do
    get :show, :id => repo.id
    assert_redirected_to repo_url
    assert_equal "Repo with ID #{repo.id} could not be found", flash[:alert]
  end

end
