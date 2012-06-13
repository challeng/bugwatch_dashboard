require 'test_helper'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class CommitHookTests < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    CommitHook
  end

  def repo_params
    {:name => 'test_repo', :url => 'path/to/repo'}
  end

  def get_payload(commit_params, repository_params=repo_params, ref="refs/heads/master")
    {:payload => JSON.dump(:repository => repository_params, :commits => commit_params, :ref => ref)}
  end

  test "POST /hook enqueues analysis worker for commit" do
    commit_params = [{:id => 'xxx'}]
    Resque::Job.expects(:create).
        with(repo_params[:name].to_sym, CommitAnalysisWorker, repo_params[:name], repo_params[:url], 'xxx')
    post '/hook', get_payload(commit_params)
  end

  test "POST /hook enqueues multiple commits" do
    commit_params = [{:id => 'xxx'}, {:id => 'zzz'}]
    Resque::Job.expects(:create).
        with(repo_params[:name].to_sym, CommitAnalysisWorker, repo_params[:name], repo_params[:url], 'xxx')
    Resque::Job.expects(:create).
        with(repo_params[:name].to_sym, CommitAnalysisWorker, repo_params[:name], repo_params[:url], 'zzz')
    post '/hook', get_payload(commit_params)
  end

  test "POST /hook does not enqueue if ref is not master" do
    payload = get_payload([:id => 'xxx'], repo_params, "refs/heads/not_master")
    Resque::Job.expects(:create).never
    post '/hook', payload
  end

  test "POST /hook does not enqueue if name not valid" do
    payload = get_payload([:id => 'xxx'], repo_params.merge(:name => "sudo rm -rf"))
    Resque::Job.expects(:create).never
    post '/hook', payload
  end

  test "POST /hook does not enqueue if url not valid" do
    payload = get_payload([:id => 'xxx'], repo_params.merge(:url => "sudo rm -rf"))
    Resque::Job.expects(:create).never
    post '/hook', payload
  end

  test "POST /hook does not enqueue if sha not valid" do
    payload = get_payload([:id => 'sudo rm -rf'])
    Resque::Job.expects(:create).never
    post '/hook', payload
  end

  test "POST /hook does not enqueue if any shas are not valid" do
    payload = get_payload([:id => 'xxx', :id => 'invalid sha'])
    Resque::Job.expects(:create).never
    post '/hook', payload
  end

  test "POST /hook enqueues worker if url is a proxy and not uri" do
    payload = get_payload([:id => 'xxx'], repo_params.merge(:url => "git@git:test_repo.git"))
    Resque::Job.expects(:create)
    post '/hook', payload
  end

end