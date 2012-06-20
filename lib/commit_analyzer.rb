class CommitAnalyzer

  def initialize(repo)
    @repo = repo
  end

  def call(bugwatch_commit)
    grit_commit = bugwatch_commit.grit.extend(CommitFu::FlogCommit)
    user = User.find_or_create_by_email(:email => grit_commit.committer.email, :name => grit_commit.committer.name)
    Commit.find_or_create_by_sha_and_repo_id(grit_commit.sha, @repo.id, :user => user,
                                        :complexity => grit_commit.total_score, :date => grit_commit.committed_date)
    Subscription.find_or_create_by_repo_id_and_user_id(@repo.id, user.id, :notify_on_analysis => false)
  end

end