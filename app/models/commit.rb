require 'active_record_cache'

class Commit < ActiveRecord::Base

  has_many :bug_fixes
  belongs_to :repo
  belongs_to :user

  after_create :analyze

  private

  def analyze
    fix_cache = self.repo.git_fix_cache
    fix_cache.caching_strategy = ActiveRecordCache.new(self)
    fix_cache.on_commit = method(:create_user_and_subscription)
    fix_cache.add(self.sha)
    fix_cache.write_bug_cache
    deliver_alerts(fix_cache)
  end

  def create_user_and_subscription(commit)
    user = User.find_or_create_by_email(:email => commit.committer.email, :name => commit.committer.name)
    self.update_attribute(:user, user)
    Subscription.find_or_create_by_repo_id_and_user_id(self.repo.id, user.id)
  end

  def create_alert(bug_fix)
    Alert.create(:commit => self, :file => bug_fix.file, :klass => bug_fix.klass, :function => bug_fix.function)
  end

  def deliver_alerts(fix_cache)
    alerts = fix_cache.alerts(self.sha).map &method(:create_alert)
    NotificationMailer.alert(alerts, :to => self.user.email).deliver if send_alerts?(alerts)
  end

  def send_alerts?(alerts)
    user_subscription = Subscription.find_by_repo_id_and_user_id(self.repo.id, self.user.id)
    !alerts.empty? && user_subscription.notify_on_analysis
  end

end
