require 'active_record_cache'

class Commit < ActiveRecord::Base

  has_many :bug_fixes
  belongs_to :repo

  after_create :analyze

  private

  def analyze
    fix_cache = self.repo.git_fix_cache
    fix_cache.caching_strategy = ActiveRecordCache.new(self)
    fix_cache.on_commit = method(:create_user_and_subscription)
    fix_cache.add(self.sha)
    fix_cache.write_bug_cache
    fix_cache.alerts(self.sha).each do |bug_fix|
      Alert.create(:commit => self, :file => bug_fix.file, :klass => bug_fix.klass, :function => bug_fix.function)
    end
  end

  def create_user_and_subscription(commit)
    user = User.find_or_create_by_email(:email => commit.committer.email, :name => commit.committer.name)
    Subscription.find_or_create_by_repo_id_and_user_id(self.repo.id, user.id)
  end

end
