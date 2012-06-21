require 'test_helper'
require 'api/zendesk_api'

class ZendeskApiTest < Test::Unit::TestCase

  test ".tickets calls tickets api" do
    sut = ZendeskApi
    username = "username"
    token = "token"
    organization = "test"
    HTTParty.expects(:get).with("https://#{organization}.zendesk.com/api/v2/tickets.json",
                                    :basic_auth => {:username => "#{username}/token", :password => token})
    sut.tickets(username, token, organization)
  end

end