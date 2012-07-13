require 'test_helper'

class DefectsControllerTest < ActionController::TestCase

  def setup
    logged_in!
  end

  def repo
    @repo ||= repos(:test_repo)
  end

  test "GET#index retrieves pivotal defects for repo" do
    get :index, {:repo_id => repo.id}
    assert_equal [defects(:pivotal)], assigns(:pivotal_defects)
  end

  test "GET#index retrieves zendesk defects for repo" do
    get :index, {:repo_id => repo.id}
    assert_equal [defects(:zendesk)], assigns(:zendesk_defects)
  end

  test "GET#index retrieves production releases for repo" do
    release = repo.releases.create! deploy_date: DateTime.now, env: "production"
    get :index, {:repo_id => repo.id}
    assert_equal [release], assigns(:releases)
  end

end
