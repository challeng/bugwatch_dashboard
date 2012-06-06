require "sinatra/base"

class DefectHook < Sinatra::Base

  get '/defect' do
    priority = params['priority']
    title = params['title']
    ticket_id = params['id']
    Defect.create!(:priority => priority, :title => title, :ticket_id => ticket_id)
    "OK"
  end

end