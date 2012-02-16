class CommitAnalysisWorker
  class << self

    def perform(repo_name, repo_url, commit_sha)
      repo = Repo.find_or_create_by_name_and_url(repo_name, repo_url)
      repo.commits << Commit.new(:sha => commit_sha)
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error e
    end

  end
end