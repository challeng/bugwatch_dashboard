require 'grit'
require 'active_record_cache'
require 'commit_analyzer'
require 'commit_analyzer_dwi'

class CommitAnalysisWorker
  class << self

    def perform(repo_name, repo_url, commit_sha)
      Grit::Git.git_timeout = 100000
      Grit::Git.git_max_size = 1000000000
      repo = Repo.find_or_create_by_name_and_url(repo_name, repo_url)
      git_analyzer = repo.git_analyzer
      fix_cache_analyzer = Bugwatch::FixCacheAnalyzer.new(git_analyzer.repo, repo.bug_fixes)
      git_analyzer.on_commit << CommitAnalyzer.new(repo)
      git_analyzer.on_commit << CommitAnalyzerDWI.new
      git_analyzer.on_commit << fix_cache_analyzer
      git_analyzer.add(commit_sha)
      commit = Commit.find_by_sha_and_repo_id(commit_sha, repo.id)
      deliver_alerts(commit, fix_cache_analyzer)
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error e
    end

    private

    def deliver_alerts(commit, fix_cache)
      existing_alerts = commit.user.alerts.any?
      alerts = create_alerts(commit, fix_cache)
      if send_alert?(alerts, commit)
        if existing_alerts
          NotificationMailer.alert(alerts, commit).deliver
        else
          NotificationMailer.welcome(alerts, commit).deliver
        end
      end
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