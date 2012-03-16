require 'test_helper'

class ReposControllerTest < ActionController::TestCase

  def grit_commit
    @grit_commit ||= stub(:diffs => [stub("Diff", :diff => "diff text")] * 2, :scores => [], :short_message => "")
  end

  attr_reader :user, :repo, :subscription, :commit

  def setup
    logged_in!
    Repo.any_instance.stubs(:git_fix_cache).returns(stub(:cache => Bugwatch::FixCache.new(10)))
    Commit.any_instance.stubs(:grit).returns(grit_commit)
    @user = users(:test_user)
    @repo = repos(:test_repo)
    @subscription = subscriptions(:test_subscription)
    @commit = commits(:test_commit)
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

  test "GET#show assigns repo presenter" do
    presenter = RepoPresenter.new(repo)
    RepoPresenter.expects(:new).with(repo).returns(presenter)
    get :show, :id => repo.id
    assert_equal presenter, assigns(:repo_presenter)
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

  test "GET#file adds .rb extension to filename" do
    get :file, :id => commit.repo.id, :filename => "path/to/file"
    assert_equal "path/to/file.rb", assigns(:filename)
  end

  test "GET#file gets related bug fixes to file" do
    bug_fix = BugFix.create(:file => "path/to/file.rb", :klass => "Test", :function => "abc", :commit => commit)
    get :file, :id => commit.repo.id, :filename => "path/to/file"
    assert_equal [bug_fix], assigns(:related_bug_fixes)
  end

end
