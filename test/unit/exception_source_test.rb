require 'test_helper'
require 'exception_source'

class ExceptionSourceTest < ActiveSupport::TestCase

  test ".deploy_before exists" do
    assert_nil ExceptionSource.deploy_before("sha")
  end

end