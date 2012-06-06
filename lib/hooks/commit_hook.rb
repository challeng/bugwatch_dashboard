require "sinatra/base"
require 'commit_analysis_worker'

class CommitHook < Sinatra::Base

  post '/hook' do
    payload = JSON.parse(params['payload'])
    repository = payload['repository']
    commits = payload['commits']
    if payload['ref'] == "refs/heads/master"
      commits.each do |commit|
        Resque::Job.create(repository['name'].to_sym, CommitAnalysisWorker,
                           repository['name'], repository['url'], commit['id'])
      end
    end
    "OK"
  end

end