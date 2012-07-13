require 'api/zendesk_api'

class ZendeskService

  class << self

    OPEN_STATUSES = %w(new open pending)
    CLOSED_STATUSES = %w(solved)

    def activity(activity_data)
      target_repo, _ = ZendeskConfig.repo_config_by_secret(activity_data["secret"])
      return unless target_repo
      ticket_id = activity_data["id"]
      repo = Repo.find_by_name! target_repo
      existing_ticket = repo.zendesk_defects.find_by_ticket_id ticket_id
      if existing_ticket
        update_defect(existing_ticket, activity_data)
      else
        create_defect(activity_data, repo)
      end
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def import(secret)
      repo_name, config_data = ZendeskConfig.repo_config_by_secret(secret)
      return unless repo_name
      repo = Repo.find_by_name! repo_name
      json = JSON.load(ZendeskApi.tickets(config_data["username"], config_data["token"], config_data["organization"]))
      tickets = json["tickets"] || []
      problem_ticket_data(tickets, repo, &method(:create_defect))
    rescue ActiveRecord::RecordNotFound
      nil
    end

    private

    def create_defect(activity_data, repo)
      ticket_id = activity_data["id"]
      status = activity_data["status"]
      priority = activity_data["priority"]
      title = activity_data["subject"]
      date = activity_data["created_at"]
      resolved_status = resolve_status(status)
      ZendeskDefect.find_or_create_by_ticket_id_and_repo_id(
          ticket_id, repo.id, priority: priority, title: title, status: resolved_status, date: date)
    end

    def update_defect(existing_ticket, activity_data)
      status = activity_data["status"]
      existing_ticket.resolve! if resolved? status
    end

    def resolve_status(status)
      resolved?(status) ? ZendeskDefect::CLOSED : ZendeskDefect::OPEN
    end

    def resolved?(status)
      CLOSED_STATUSES.include? status.downcase
    end

    def problem_ticket_data(tickets, repo, &block)
      problem_tickets(tickets).each do |ticket_data|
        block.call(ticket_data, repo)
      end
    end

    def problem_tickets(tickets)
      tickets.select do |ticket_data|
        ticket_data["type"] == "problem"
      end
    end

    def get_tickets_json(config_data)
      HTTParty.get("https://#{config_data["organization"]}.zendesk.com/api/v2/tickets.json",
                   {:basic_auth => {:username => "#{config_data["username"]}/token", :password => config_data["token"]}})
    end


  end

end