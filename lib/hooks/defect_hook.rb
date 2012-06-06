require "sinatra/base"

class DefectHook < Sinatra::Base

  post '/defect' do
    defect_params = params['payload']
    priority, title, ticket_id = defect_params.split("|")
    Defect.create!(:priority => priority, :title => title, :ticket_id => ticket_id)
    "OK"
  end

end