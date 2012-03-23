require 'active_record_cache'

class Commit < ActiveRecord::Base

  has_many :bug_fixes, :dependent => :destroy
  has_many :alerts, :dependent => :destroy
  belongs_to :repo
  belongs_to :user

  def accumulated_commit_scores
    grit.scores.map do |(file_name, before_score, after_score)|
      [file_name, get_accumulated_score(after_score, before_score)]
    end
  end

  def diffs
    grit.diffs.map(&:diff)
  end

  def message
    grit.short_message
  end

  private

  def get_accumulated_score(after_score, before_score)
    if before_score && after_score
      after_score - before_score
    else
      0.0
    end
  end

  def grit
    grit_commit = self.repo.grit.commit(self.sha)
    grit_commit.extend(CommitFu::FlogCommit)
    grit_commit
  end

end
