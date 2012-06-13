require "sinatra/base"
require 'commit_analysis_worker'

class CommitHook < Sinatra::Base
  post '/hook' do
    payload = JSON.parse(params['payload'])
    repository = payload['repository']
    commits = payload['commits']
    if valid_data?(repository, commits) && payload['ref'] == "refs/heads/master"
      commits.each do |commit|
        Resque::Job.create(repository['name'].to_sym, CommitAnalysisWorker,
                           repository['name'], repository['url'], commit['id'])
      end
    end
    "OK"
  end

  private

  def valid_data?(repository_data, commits)
    alphanumeric?(repository_data['name']) &&
        commits.all? {|commit_data| sha? commit_data['id'] } &&
        url?(repository_data['url'])
  end

  def alphanumeric?(data)
    data.match(/^[A-Za-z0-9_-]+$/)
  end

  def sha?(data)
    data.match(/^[a-f0-9]+$/)
  end

  def url?(data)
    URI.parse(data)
  rescue URI::InvalidURIError
    data.match(/^git\@git\:[A-Za-z0-9_-]+\.git$/)
  end

end