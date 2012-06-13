require "sinatra/base"

class ZendeskHook < Sinatra::Base

  get '/zendesk' do
    priority = params['priority']
    title = params['title']
    ticket_id = params['id']
    ZendeskDefect.create!(:priority => priority, :title => title, :ticket_id => ticket_id)
    "OK"
  end

end