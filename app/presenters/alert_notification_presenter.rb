class AlertNotificationPresenter

  attr_reader :alerts

  def initialize(alerts)
    @alerts = alerts
  end

  def files
    alerts.each_with_object({}) do |alert, result|
      result[alert.file] ||= Hash.new {|h, k| h[k] = []}
      result[alert.file][alert.klass] << alert
    end
  end

end