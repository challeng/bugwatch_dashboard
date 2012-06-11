class Defect < ActiveRecord::Base

  belongs_to :repo

  after_initialize :set_status

  private

  def set_status
    self.status = 0 if self.status.nil?
  end

end
