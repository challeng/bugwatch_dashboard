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

  def get_payload(commit_params, repository_params=repo_params)
    {:payload => JSON.dump(:repository => repository_params, :commits => commit_params)}
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

end