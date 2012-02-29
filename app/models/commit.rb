require 'active_record_cache'

class Commit < ActiveRecord::Base

  has_many :bug_fixes
  has_many :alerts
  belongs_to :repo
  belongs_to :user

end
