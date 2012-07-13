class PivotalApi

  class << self

    def defects(project_id, token)
      HTTParty.get("https://www.pivotaltracker.com/services/v3/projects/#{project_id}/stories?filter=type:bug",
                  {"X-TrackerToken" => token}).body
    end

  end

end