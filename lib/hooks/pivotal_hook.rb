require "sinatra/base"
require 'nokogiri'

class PivotalHook < Sinatra::Base

  post '/pivotal' do
    begin
      xml = params["body"]
      doc = Nokogiri::XML xml
      _, story_id = (doc / "id").children.map &:text
      project_id = (doc / "project_id").text
      event_type = (doc / "event_type").text
      story_type = (doc / "story_type").text
      current_state = (doc / "current_state").text
      PivotalService.activity id: story_id, project_id: project_id, event_type: event_type,
                              story_type: story_type, current_state: current_state
    rescue Exception => e
      Rails.logger.error e
    end
    "OK"
  end

end