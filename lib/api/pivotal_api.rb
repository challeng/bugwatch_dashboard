class PivotalApi

  class << self

    def defects(project_id, token)
      HTTParty.get("http://www.pivotaltracker.com/services/v3/projects/#{project_id}/stories?filter=type:bug",
                  {"X-TrackerToken" => token})
    end

  end

end