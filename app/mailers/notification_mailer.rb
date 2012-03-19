class NotificationMailer < ActionMailer::Base

  def alert(alerts, user, options={})
    @presenter = AlertNotificationPresenter.new(alerts)
    @user = user
    mail(:from => AppConfig.mailer['from'], :subject => "Bugwatch Alert", :to => user.email)
  end

  def welcome(alerts, user)
    @presenter = AlertNotificationPresenter.new(alerts)
    @user = user
    mail(:to => user.email)
  end

end
