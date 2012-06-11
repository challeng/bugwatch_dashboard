class Defect < ActiveRecord::Base

  belongs_to :repo

  after_initialize :set_status

  OPEN = 0
  CLOSED = 1

  scope :open_defects, where(status: OPEN)

  def resolve!
    update_attribute(:status, CLOSED)
  end

  private

  def set_status
    self.status = OPEN if self.status.nil?
  end

end
