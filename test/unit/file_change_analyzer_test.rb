require 'test_helper'

class FileChangeAnalyzerTest < ActiveSupport::TestCase

  attr_reader :commit

  def setup
    @commit = Bugwatch::Commit.new(stub)
  end

  test "#call sends notification email to group if a file they subscribe to are touched" do
    email_list = %w(test@example.com test2@example.com)
    AppConfig.stubs(:file_changes).returns({"group1" => {"files" => %w(file.rb file1.rb), "emails" => email_list}})
    commit.stubs(:files).returns(['file1.rb'])
    mailer = stub
    NotificationMailer.expects(:file_change).with(["file1.rb"], email_list).returns(mailer)
    mailer.expects(:deliver)
    FileChangeAnalyzer.call(commit)
  end

  test "#call sends notification to multiple groups" do
    group_email_list = %w(test@example.com test2@example.com)
    group2_email_list = %w(test3@example.com test4@example.com)
    AppConfig.stubs(:file_changes).returns({"group1" => {"files" => %w(file.rb), "emails" => group_email_list},
                                            "group2" => {"files" => %w(file.rb), "emails" => group2_email_list}})
    commit.stubs(:files).returns(%w(file.rb))
    mailer1 = stub
    mailer2 = stub
    NotificationMailer.expects(:file_change).with(%w(file.rb), group_email_list).returns(mailer1)
    NotificationMailer.expects(:file_change).with(%w(file.rb), group2_email_list).returns(mailer2)
    mailer1.expects(:deliver)
    mailer2.expects(:deliver)
    FileChangeAnalyzer.call(commit)
  end

  test "#call does not send email if no groups" do
    # Do not call files unless necessary
    commit.expects(:files).never
    AppConfig.stubs(:file_changes).returns({})
    NotificationMailer.expects(:file_change).never
    FileChangeAnalyzer.call(commit)
  end

  test "#call does not send email to groups with subscribed files not modified" do
    AppConfig.stubs(:file_changes).returns({"group1" => {"files" => %w(file.rb), "emails" => %w(test@example.com)}})
    commit.stubs(:files).returns(%w(some_file.rb))
    NotificationMailer.expects(:file_change).never
    FileChangeAnalyzer.call(commit)
  end

end