require "sinatra/base"

class ZendeskHook < Sinatra::Base

  get '/zendesk' do
    begin
      priority = params['priority']
      title = params['title']
      ticket_id = params['id']
      status = params['status']
      secret = params['secret']
      ZendeskService.activity(priority: priority, title: title, id: ticket_id, status: status, secret: secret)
    rescue Exception => e
      Rails.logger.error e
    end
    "OK"
  end

end