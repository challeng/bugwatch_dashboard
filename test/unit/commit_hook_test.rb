#require File.expand_path('./../../test_helper', __FILE__)

require 'test/unit'
require 'rack/test'
require 'mocha'
require File.expand_path('./../../../lib/commit_analysis_worker', __FILE__)
require File.expand_path('./../../../lib/commit_hook', __FILE__)
require 'resque'

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

  def test_enqueues_analysis_worker_for_commit
    commit_params = [{:id => 'XXX'}]
    Resque::Job.expects(:create).
        with(repo_params[:name].to_sym, CommitAnalysisWorker, repo_params[:name], repo_params[:url], 'XXX')
    post '/add', get_payload(commit_params)
  end

  def test_enqueues_multiple_commits
    commit_params = [{:id => 'XXX'}, {:id => 'ZZZ'}]
    Resque::Job.expects(:create).
        with(repo_params[:name].to_sym, CommitAnalysisWorker, repo_params[:name], repo_params[:url], 'XXX')
    Resque::Job.expects(:create).
        with(repo_params[:name].to_sym, CommitAnalysisWorker, repo_params[:name], repo_params[:url], 'ZZZ')
    post '/add', get_payload(commit_params)
  end

end