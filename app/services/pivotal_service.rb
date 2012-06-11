class PivotalService

  def self.activity(activity_data)
    event_type, story_type = activity_data["event_type"], activity_data["story_type"]
    return unless story_type == "bug"
    if event_type == "story_create"
      project_id, title, ticket_id = activity_data["project_id"], activity_data["story_name"], activity_data["id"]
      repo_name = repo_name_by_project_id(project_id)
      if repo_name
        repo = Repo.find_by_name! repo_name
        PivotalDefect.create! title: title, ticket_id: ticket_id, repo: repo
      end
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.config
    AppConfig.pivotal_projects
  end

  private

  def self.repo_name_by_project_id(project_id)
    config.each do |(repo_name, project_ids)|
      return repo_name if project_ids.include? project_id
    end
    nil
  end

end