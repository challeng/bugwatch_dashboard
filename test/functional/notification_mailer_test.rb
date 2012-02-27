require 'test_helper'

class NotificationMailerTest < ActionMailer::TestCase

  tests NotificationMailer

  #test "alert" do
  #  pending 'Figure out Message-ID'
  #  AppConfig.stubs(:mailer).returns({'from' => 'test@example'})
  #  @expected.from = 'test@example'
  #  @expected.subject = 'Bugwatch Alert'
  #  assert_equal @expected.encoded, NotificationMailer.alert.encoded
  #end

end
