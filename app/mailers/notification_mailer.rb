class NotificationMailer < ActionMailer::Base

  def alert(alerts, user, options={})
    @presenter = AlertNotificationPresenter.new(alerts)
    @user = user
    mail(:from => AppConfig.mailer['from'], :subject => "Bugwatch Alert")
  end

end
