require 'sinatra/base'
require 'json'
require 'resque'
require_relative "post_receive"

module Bugwatch
  class Server < Sinatra::Base

    post "/add" do
      payload = JSON.parse(params["payload"])
      repository_name = payload["repository"]["name"]
      repository_url = payload["repository"]["url"]
      commits = payload["commits"]
      commits.each do |commit|
        Resque::Job.create(repository_name.to_sym, PostReceive, repository_name, repository_url, commit["id"])
      end
      "Jobs submitted"
    end

    get '/' do
      %Q{
      <html>
      <body>
      <form action="/add" method="POST">
        <textarea name="payload"></textarea>
        <input type="submit" />
      </form>
      </body>
      </html>
      }
    end

  end
end
