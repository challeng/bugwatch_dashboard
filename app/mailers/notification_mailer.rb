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

end
