require 'test_helper'

class AlertsControllerTest < ActionController::TestCase

  def setup
    logged_in!
  end

  def alert
    alerts(:test_alert)
  end

  def repo
    repos(:test_repo)
  end

  def subscription
    subscriptions(:test_subscription)
  end

  test "GET#show retrieves alert by id" do
    get :show, :repo_id => repo.id, :id => alert.id
    assert_equal alert, assigns(:alert)
  end

  test "GET#show redirects to alerts index if alert commit doesnt belong to user subscriped repo" do
    alert.update_attribute(:commit, nil)
    get :show, :repo_id => repo.id, :id => alert.id
    assert_redirected_to repo_alerts_path(repo)
    assert_equal "Alert with ID #{alert.id} could not be found", flash[:alert]
  end

  test "GET#show redirects to repos index if user does not subscribe to repo" do
    subscriptions(:test_subscription).destroy
    get :show, :repo_id => repo.id, :id => alert.id
    assert_redirected_to repos_path
    assert_equal "Repo with ID #{repo.id} could not be found", flash[:alert]
  end

  test "GET#show gets related bug fixes to alert" do
    bug_fix = BugFix.create(:file => alert.file, :klass => alert.klass, :function => alert.function, :commit => commits(:test_commit))
    bug_fix2 = BugFix.create(:file => alert.file, :klass => alert.klass, :function => alert.function, :commit => commits(:test_commit))
    get :show, :repo_id => repo.id, :id => alert.id
    assert_equal [bug_fix, bug_fix2], assigns(:related_bug_fixes)
  end

  test "GET#index retrieves alerts for repo" do
    commit = commits(:test_commit)
    alert1 = Alert.create!(:commit => commit)
    alert2 = Alert.create!(:commit => commit)
    get :index, :repo_id => repo.id
    assert_true assigns(:alerts).include?(alert1)
    assert_true assigns(:alerts).include?(alert2)
  end

  test "GET#index retrieves user alerts for repo" do
    commit = commits(:test_commit)
    alert1 = Alert.create!(:commit => commit)
    alert2 = Alert.create!()
    get :index, :repo_id => repo.id
    assert_true assigns(:user_alerts).include?(alert1)
    assert_false assigns(:user_alerts).include?(alert2)
  end

  test "GET#index redirects to index if user has not subscribed to repo" do
    subscription.destroy
    get :index, :repo_id => repo.id
    assert_redirected_to repos_path
    assert_equal "Repo with ID #{repo.id} could not be found", flash[:alert]
  end


end
