require "sinatra/base"

class CommitHook < Sinatra::Base
  post '/add' do
    payload = JSON.parse(params['payload'])
    repository = payload['repository']
    commits = payload['commits']
    commits.each do |commit|
      Resque::Job.create(repository['name'].to_sym, CommitAnalysisWorker,
                         repository['name'], repository['url'], commit['id'])
    end
  end
end