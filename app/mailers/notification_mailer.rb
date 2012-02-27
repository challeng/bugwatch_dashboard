class NotificationMailer < ActionMailer::Base

  def alert(alerts, options={})
    @alerts = alerts
    mail(:from => AppConfig.mailer['from'], :subject => "Bugwatch Alert")
  end

end
