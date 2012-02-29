require 'test_helper'

class AlertNotificationPresenterTest < Test::Unit::TestCase

  test "aggregates classes and functions by files and classes" do
    alert1 = Alert.new(:file => "file.rb", :klass => "Test", :function => "method_name")
    alert2 = Alert.new(:file => "file.rb", :klass => "OtherClass", :function => "method_name")
    presenter = AlertNotificationPresenter.new([alert1, alert2])
    assert_equal({"file.rb" => {"Test" => [alert1], "OtherClass" => [alert2]}}, presenter.files)
  end

  test "aggregates seperate files" do
    alert1 = Alert.new(:file => "file.rb", :klass => "Test", :function => "method_name")
    alert2 = Alert.new(:file => "file2.rb", :klass => "OtherClass", :function => "method_name")
    presenter = AlertNotificationPresenter.new([alert1, alert2])
    expected = {"file.rb" => {"Test" => [alert1]}, "file2.rb" => {"OtherClass" => [alert2]}}
    assert_equal expected, presenter.files
  end

end