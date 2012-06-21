class PivotalApi

  class << self

    def defects(project_id)
      HTTParty.get("http://www.pivotaltracker.com/services/v3/projects/#{project_id}/stories?filter=type:bug")
    end

  end

end