require 'test_helper'

class FileChangeAnalyzerTest < ActiveSupport::TestCase

  attr_reader :commit, :sut, :email_list, :mailer, :repo_name, :emails_to_ignore, :diff, :filename

  def setup
    @email_list = %w(test@example.com test2@example.com)
    @emails_to_ignore = %w(bad_committer@example.com)
    @mailer = stub("NotificationMailer")
    @repo_name = "repo_name"
    @filename = 'file.rb'

    @commit = Bugwatch::Commit.new(stub("Grit::Commit", :committer => stub(:email => "committer@example.com")))
    @commit.stubs(:diffs).returns([])
    @commit.stubs(:files).returns([filename])

    @sut = FileChangeAnalyzer.new(Repo.new(name: repo_name))
  end

  def get_config(files)
    {repo_name => {"group1" => {"files" => files, "emails" => email_list, "ignore" => emails_to_ignore}}}
  end

  test "#call sends notification email that includes the diffs for the right files" do
    AppConfig.stubs(:file_changes).returns(get_config([filename]))

    diff = Bugwatch::Diff.new(stub)
    diff.stubs(:path).returns(filename)
    diff.stubs(:diff).returns('diff_text')
    diff2 = Bugwatch::Diff.new(stub)
    diff2.stubs(:path).returns('bad_file.rb')
    diff2.stubs(:diff).returns("bad diff")
    commit.stubs(:diffs).returns([diff, diff2])

    NotificationMailer.expects(:file_change).with([filename], email_list, commit, @sut.repo, 'diff_text').returns(mailer)
    mailer.expects(:deliver)

    sut.call(commit)
  end

  test "#call sends notification email to group if a file they subscribe to are touched" do
    AppConfig.stubs(:file_changes).returns(get_config(%w(file.rb file1.rb)))
    NotificationMailer.expects(:file_change).with([filename], email_list, commit, @sut.repo, '').returns(mailer)
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
    NotificationMailer.expects(:file_change).with(%w(file.rb), group_email_list, commit, @sut.repo, '').returns(mailer)
    NotificationMailer.expects(:file_change).with(%w(file.rb), group2_email_list, commit, @sut.repo, '').returns(mailer2)
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

  test "#call does not send email if the committer's email is on the ignore list" do
    AppConfig.stubs(:file_changes).returns({repo_name => {"group1" => {"files" => ["file1.rb"], "emails" => email_list, "ignore" => [commit.grit.committer.email]}}})
    FileChangeAnalyzer.expects(:file_changes).never
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
    dir_filename = "app/#{filename}"

    diff = Bugwatch::Diff.new(stub)
    diff.stubs(:path).returns(dir_filename)
    diff.stubs(:diff).returns('diff_text')

    commit.stubs(:files).returns([dir_filename])
    commit.stubs(:diffs).returns([diff])
    NotificationMailer.expects(:file_change).with([dir_filename], email_list, commit, @sut.repo, 'diff_text').returns(mailer)
    mailer.expects(:deliver)
    sut.call(commit)
  end

  test "#call does not send email if file patterns on different repository" do
    AppConfig.stubs(:file_changes).returns(get_config(%w(file.rb)))
    commit.stubs(:files).returns(%w(file.rb))
    NotificationMailer.expects(:file_change).never
    sut = FileChangeAnalyzer.new(Repo.new(name: "not_the_right_repo_name"))
    sut.call(commit)
  end

end