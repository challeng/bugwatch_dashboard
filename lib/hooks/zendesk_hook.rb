require "sinatra/base"

class ZendeskHook < Sinatra::Base

  get '/zendesk' do
    begin
      priority = params['priority']
      subject = params['subject']
      ticket_id = params['id']
      status = params['status']
      secret = params['secret']
      ZendeskService.activity(priority: priority, subject: subject, id: ticket_id, status: status, secret: secret)
    rescue Exception => e
      Rails.logger.error e
    end
    "OK"
  end

end