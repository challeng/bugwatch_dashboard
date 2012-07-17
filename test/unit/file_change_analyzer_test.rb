require 'test_helper'

class FileChangeAnalyzerTest < ActiveSupport::TestCase

  attr_reader :commit, :sut, :email_list, :mailer, :repo_name

  def setup
    @commit = Bugwatch::Commit.new(stub)
    @email_list = %w(test@example.com test2@example.com)
    @mailer = stub("NotificationMailer")
    @repo_name = "repo_name"
    @sut = FileChangeAnalyzer.new(repo_name)
  end

  def get_config(files)
    {repo_name => {"group1" => {"files" => files, "emails" => email_list}}}
  end

  test "#call sends notification email to group if a file they subscribe to are touched" do
    AppConfig.stubs(:file_changes).returns(get_config(%w(file.rb file1.rb)))
    commit.stubs(:files).returns(['file1.rb'])
    NotificationMailer.expects(:file_change).with(["file1.rb"], email_list).returns(mailer)
    mailer.expects(:deliver)
    sut.call(commit)
  end

  test "#call sends notification to multiple groups" do
    group_email_list = %w(test@example.com test2@example.com)
    group2_email_list = %w(test3@example.com test4@example.com)
    AppConfig.stubs(:file_changes).returns({repo_name => {"group1" => {"files" => %w(file.rb), "emails" => group_email_list},
                                            "group2" => {"files" => %w(file.rb), "emails" => group2_email_list}}})
    commit.stubs(:files).returns(%w(file.rb))
    mailer2 = stub
    NotificationMailer.expects(:file_change).with(%w(file.rb), group_email_list).returns(mailer)
    NotificationMailer.expects(:file_change).with(%w(file.rb), group2_email_list).returns(mailer2)
    mailer.expects(:deliver)
    mailer2.expects(:deliver)
    sut.call(commit)
  end

  test "#call does not send email if no groups" do
    commit.expects(:files).never
    AppConfig.stubs(:file_changes).returns({})
    NotificationMailer.expects(:file_change).never
    sut.call(commit)
  end

  test "#call does not send email to groups with subscribed files not modified" do
    AppConfig.stubs(:file_changes).returns(get_config(%w(file.rb)))
    commit.stubs(:files).returns(%w(some_file.rb))
    NotificationMailer.expects(:file_change).never
    sut.call(commit)
  end

  test "#call matches file patterns" do
    AppConfig.stubs(:file_changes).returns(get_config(%w(app/*.rb)))
    commit.stubs(:files).returns(%w(app/file.rb))
    NotificationMailer.expects(:file_change).with(%w(app/file.rb), email_list).returns(mailer)
    mailer.expects(:deliver)
    sut.call(commit)
  end

  test "#call does not send email if file patterns on different repository" do
    AppConfig.stubs(:file_changes).returns(get_config(%w(file.rb)))
    commit.stubs(:files).returns(%w(file.rb))
    NotificationMailer.expects(:file_change).never
    sut = FileChangeAnalyzer.new("not_the_right_repo_name")
    sut.call(commit)
  end

end