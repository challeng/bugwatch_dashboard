class Commit < ActiveRecord::Base

  has_many :bug_fixes
  belongs_to :repo

  after_create :analyze

  private

  def analyze
    fix_cache = self.repo.git_fix_cache
    fix_cache.caching_strategy = ActiveRecordCache.new(self)
    fix_cache.add(self.sha)
    fix_cache.write_bug_cache
  end

end
