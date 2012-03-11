class CommitAnalysisWorker
  class << self

    def perform(repo_name, repo_url, commit_sha)
      repo = Repo.find_or_create_by_name_and_url(repo_name, repo_url)
      fix_cache = repo.git_fix_cache
      fix_cache.caching_strategy = ActiveRecordCache.new(repo)
      fix_cache.on_commit = method(:create_and_associate).to_proc.curry[repo]
      fix_cache.add(commit_sha)
      fix_cache.write_bug_cache
      commit = Commit.find_by_sha_and_repo_id(commit_sha, repo.id)
      deliver_alerts(commit, fix_cache)
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error e
    end

    private

    def create_and_associate(repo, grit_commit)
      grit_commit.extend(CommitFu::FlogCommit)
      user = User.find_or_create_by_email(:email => grit_commit.committer.email, :name => grit_commit.committer.name)
      Commit.find_or_create_by_sha_and_repo_id(grit_commit.sha, repo.id, :user => user, :complexity => grit_commit.total_score)
      Subscription.find_or_create_by_repo_id_and_user_id(repo.id, user.id)
    end

    def deliver_alerts(commit, fix_cache)
      alerts = create_alerts(commit, fix_cache)
      NotificationMailer.alert(alerts, commit.user, :to => commit.user.email).deliver if send_alert?(alerts, commit)
    end

    def create_alerts(commit, fix_cache)
      fix_cache.alerts(commit.sha).map do |bug_fix|
        Alert.create(:commit => commit, :file => bug_fix.file, :klass => bug_fix.klass, :function => bug_fix.function)
      end
    end

    def send_alert?(alerts, commit)
      user_subscription = Subscription.find_by_repo_id_and_user_id(commit.repo.id, commit.user.id)
      !alerts.empty? && user_subscription.notify_on_analysis
    end

  end
end