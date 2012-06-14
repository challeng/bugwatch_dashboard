class ZendeskService

  class << self

    def activity(activity_data)
      return if config.empty?
      repo = Repo.find_by_name! config[activity_data["secret"]]
      ticket_id = activity_data["id"]
      priority = (activity_data["priority"] || "").downcase
      title = activity_data["title"]
      status = resolve_status(activity_data["status"])
      ZendeskDefect.create! ticket_id: ticket_id, priority: priority, title: title, status: status, repo: repo
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def config
      AppConfig.zendesk
    end

    private

    def resolve_status(status)
      case status.downcase
        when "new", "open", "pending" then ZendeskDefect::OPEN
        when "solved" then ZendeskDefect::CLOSED
        else nil
      end
    end

  end

end