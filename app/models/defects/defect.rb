class Defect < ActiveRecord::Base

  belongs_to :repo

  after_initialize :set_status

  OPEN = 0
  CLOSED = 1
  ARCHIVED = 2

  scope :open_defects, where(status: OPEN)

  def resolve!
    update_attribute(:status, CLOSED)
  end

  def archive!
    update_attribute(:status, ARCHIVED)
  end

  def priority=(priority)
    self[:priority] = priority.downcase if priority
  end

  private

  def set_status
    self.status = OPEN if self.status.nil?
  end

end
