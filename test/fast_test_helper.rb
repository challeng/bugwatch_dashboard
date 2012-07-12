ENV["RAILS_ENV"] = "test"
require 'test-unit'
require 'mocha'

module Rails

  def root
    File.expand_path('.')
  end

  module_function :root

end

$:.unshift File.expand_path('./lib')
$:.unshift File.expand_path('./app')
require File.expand_path('./config/initializers/config')
