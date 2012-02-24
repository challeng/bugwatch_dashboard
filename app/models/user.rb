class User < ActiveRecord::Base

  has_many :subscriptions
  has_many :repos, :through => :subscriptions

end
