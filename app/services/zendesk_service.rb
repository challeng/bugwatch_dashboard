class ZendeskService

  class << self

    OPEN_STATUSES = %w(new open pending)
    CLOSED_STATUSES = %w(solved)

    def activity(activity_data)
      target_repo, ticket_id, status = config[activity_data["secret"]], activity_data["id"], activity_data["status"]
      return unless target_repo
      repo = Repo.find_by_name! target_repo
      existing_ticket = repo.zendesk_defects.find_by_ticket_id ticket_id
      if existing_ticket
        update_defect(existing_ticket, status)
      else
        create_defect(activity_data, repo, ticket_id, status)
      end
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def config
      AppConfig.zendesk
    end

    private

    def create_defect(activity_data, repo, ticket_id, status)
      priority = activity_data["priority"]
      title = activity_data["title"]
      resolved_status = resolve_status(status)
      ZendeskDefect.create! ticket_id: ticket_id, priority: priority, title: title, status: resolved_status, repo: repo
    end

    def update_defect(existing_ticket, status)
      existing_ticket.resolve! if resolved? status
    end

    def resolve_status(status)
      resolved?(status) ? ZendeskDefect::CLOSED : ZendeskDefect::OPEN
    end

    def resolved?(status)
      CLOSED_STATUSES.include? status.downcase
    end

  end

end