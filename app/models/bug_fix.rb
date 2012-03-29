class BugFix < ActiveRecord::Base
  belongs_to :commit

  def bugwatch
    Bugwatch::BugFix.new(:file => file, :klass => klass, :function => function, :date => date_fixed, :sha => commit.sha)
  end
end
