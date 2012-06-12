class PivotalService

  def self.activity(activity_data)
    event_type, story_type = activity_data["event_type"], activity_data["story_type"]
    return unless story_type == "bug"
    project_id, title, ticket_id, current_state =
        activity_data["project_id"], activity_data["story_name"], activity_data["id"], activity_data["current_state"]
    case event_type
      when "story_create" then create(project_id, ticket_id, title)
      when "story_update" then update(ticket_id, current_state)
      when "story_delete" then archive(ticket_id)
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.config
    AppConfig.pivotal_projects
  end

  def self.resolved?(status_phrase)
    case status_phrase
      when "unscheduled", "started" then false
      when 'finished' then true
      else nil
    end
  end

  private

  def self.create(project_id, ticket_id, title)
    repo_name = repo_name_by_project_id(project_id)
    if repo_name
      repo = Repo.find_by_name! repo_name
      PivotalDefect.create! title: title, ticket_id: ticket_id, repo: repo
    end
  end

  def self.update(ticket_id, current_state)
    return unless resolved? current_state
    pivotal_defect = PivotalDefect.find_by_ticket_id! ticket_id
    pivotal_defect.resolve!
  end

  def self.archive(ticket_id)
    pivotal_defect = PivotalDefect.find_by_ticket_id! ticket_id
    pivotal_defect.archive!
  end

  def self.repo_name_by_project_id(project_id)
    config.each do |(repo_name, project_ids)|
      return repo_name if project_ids.include? project_id
    end
    nil
  end

end