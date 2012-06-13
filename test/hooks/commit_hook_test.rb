require 'rack_test_helper'

class CommitHookTest < Test::Unit::TestCase
  include RackTest

  def repo_params
    {:name => 'test_repo', :url => 'path/to/repo'}
  end

  def get_payload(commit_params, repository_params=repo_params, ref="refs/heads/master")
    {:payload => JSON.dump(:repository => repository_params, :commits => commit_params, :ref => ref)}
  end

  test "POST /hook enqueues analysis worker for commit" do
    commit_params = [{:id => 'XXX'}]
    Resque::Job.expects(:create).
        with(repo_params[:name].to_sym, CommitAnalysisWorker, repo_params[:name], repo_params[:url], 'XXX')
    post '/hook', get_payload(commit_params)
  end

  test "POST /hook enqueues multiple commits" do
    commit_params = [{:id => 'XXX'}, {:id => 'ZZZ'}]
    Resque::Job.expects(:create).
        with(repo_params[:name].to_sym, CommitAnalysisWorker, repo_params[:name], repo_params[:url], 'XXX')
    Resque::Job.expects(:create).
        with(repo_params[:name].to_sym, CommitAnalysisWorker, repo_params[:name], repo_params[:url], 'ZZZ')
    post '/hook', get_payload(commit_params)
  end

  test "POST /hook does not enqueue if ref is not master" do
    payload = get_payload([:id => 'XXX'], repo_params, "refs/heads/not_master")
    Resque::Job.expects(:create).never
    post '/hook', payload
  end

end