require 'yaml'

class NotificationMailer < ActionMailer::Base

  default :from => AppConfig.mailer['from']

  def alert(alerts, commit, options={})
    @presenter = AlertNotificationPresenter.new(alerts)
    @user = commit.user
    @repo = commit.repo
    mail(:subject => "Bugwatch Alert", :to => @user.email)
  end

  def welcome(alerts, commit)
    @presenter = AlertNotificationPresenter.new(alerts)
    @user = commit.user
    @repo = commit.repo
    mail(:to => @user.email, :subject => "Welcome to Bugwatch")
  end

  def file_change(files_to_email, config_data)
    @file_names = files_to_email
    email_addresses = config_data['email_addresses']

    email_addresses.each do |email|
      mail(:to => email, :subject => "Files were changed in the latest push")
    end

  end

end
