require "sinatra/base"
require 'commit_analysis_worker'

class CommitHook < Sinatra::Base
  post '/hook' do
    payload = JSON.parse(params['payload'])
    repository = payload['repository']
    commits = payload['commits']
    commits.each do |commit|
      Resque::Job.create(repository['name'].to_sym, CommitAnalysisWorker,
                         repository['name'], repository['url'], commit['id'])
    end
  end
end