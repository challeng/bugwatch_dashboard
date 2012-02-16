class Commit < ActiveRecord::Base

  belongs_to :repo

  after_create :analyze

  private

  def analyze
    commit = self.repo.repo.commit(self.sha)
    Bugwatch::FixCommit.new(commit).fixes.each do |bug_fix|
      BugFix.create(:commit => self, :file => bug_fix.file, :klass => bug_fix.klass, :function => bug_fix.function)
    end
  end

end
