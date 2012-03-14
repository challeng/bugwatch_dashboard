require 'active_record_cache'

class Commit < ActiveRecord::Base

  has_many :bug_fixes
  has_many :alerts
  belongs_to :repo
  belongs_to :user

  def accumulated_commit_scores
    grit.scores.map do |(file_name, before_score, after_score)|
      [file_name, after_score - before_score]
    end
  end

  def diffs
    grit.diffs.map(&:diff)
  end

  private

  def grit
    grit_commit = self.repo.grit.commit(self.sha)
    grit_commit.extend(CommitFu::FlogCommit)
    grit_commit
  end

end
