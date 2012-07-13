require 'api/pivotal_api'

class PivotalService

  def self.activity(activity_data)
    event_type, story_type = activity_data["event_type"], activity_data["story_type"]
    return unless story_type == "bug"
    project_id, title, ticket_id, current_state =
        activity_data["project_id"], activity_data["story_name"], activity_data["id"], activity_data["current_state"]
    case event_type
      when "story_create" then create(project_id, ticket_id, title, current_state)
      when "story_update" then update(ticket_id, current_state)
      when "story_delete" then archive(ticket_id)
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.import(project_id)
    repo_name, token = PivotalConfig.repo_name_and_token_by_project_id(project_id)
    return unless repo_name
    repo = Repo.find_by_name! repo_name
    doc = Nokogiri::XML PivotalApi.defects(project_id, token)
    each_story(doc, repo, &method(:create_defect))
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def self.resolved?(status_phrase)
    case status_phrase
      when "unscheduled", "started" then false
      when 'finished' then true
      else nil
    end
  end

  private

  def self.create(project_id, ticket_id, title, current_state)
    repo_name, _ = PivotalConfig.repo_name_and_token_by_project_id(project_id)
    if repo_name
      repo = Repo.find_by_name! repo_name
      create_defect(current_state, repo, ticket_id, title)
    end
  end

  def self.create_defect(current_state, repo, ticket_id, title)
    PivotalDefect.find_or_create_by_ticket_id_and_repo_id(ticket_id, repo.id, title: title, status: resolved_status(current_state))
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

  def self.resolved_status(current_state)
    resolved?(current_state) ? PivotalDefect::CLOSED : PivotalDefect::OPEN
  end

  def self.each_story(doc, repo, &block)
    (doc / "stories").each do |story|
      ticket_id = (story / "id").text
      title = (story / "name").text
      current_state = (story / "current_state").text
      block.call(current_state, repo, ticket_id, title)
    end
  end

end