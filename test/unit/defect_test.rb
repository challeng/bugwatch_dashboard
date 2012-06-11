require 'test_helper'

class DefectTest < ActiveSupport::TestCase

  test "defaults status to open" do
    assert_equal 0, Defect.new.status
    assert_equal 5, Defect.new(:status => 5).status
  end

end
