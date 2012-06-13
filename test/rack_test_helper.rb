require 'test_helper'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

module RackTest
  include Rack::Test::Methods

  def app
    self.class.to_s.chomp("Test").constantize
  end

end
