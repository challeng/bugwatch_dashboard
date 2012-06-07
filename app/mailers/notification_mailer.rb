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

  def mail_dwi(files_to_email)
    mail(:to => 'jim.challenger1@gmail.com', :subject => "Files were changed in DWI #{files_to_email.inspect}")
    #TODO mail to team
  end

end
