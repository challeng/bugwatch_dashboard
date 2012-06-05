class Clue < ActiveRecord::Base
  belongs_to :commit
  belongs_to :mystery
end
