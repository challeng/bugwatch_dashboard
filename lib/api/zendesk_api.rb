class ZendeskApi

  class << self

    def tickets(username, token, organization)
      HTTParty.get("https://#{organization}.zendesk.com/api/v2/tickets.json",
                 {:basic_auth => {:username => "#{username}/token", :password => token}})
    end

  end

end