class User < ActiveRecord::Base

  has_many :subscriptions
  has_many :repos, :through => :subscriptions
  has_many :commits
  has_many :alerts

end
