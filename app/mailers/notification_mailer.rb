class NotificationMailer < ActionMailer::Base

  default :from => AppConfig.mailer['from']

  def alert(alerts, user, options={})
    @presenter = AlertNotificationPresenter.new(alerts)
    @user = user
    mail(:subject => "Bugwatch Alert", :to => user.email)
  end

  def welcome(alerts, user)
    @presenter = AlertNotificationPresenter.new(alerts)
    @user = user
    mail(:to => user.email, :subject => "Welcome to Bugwatch")
  end

end
