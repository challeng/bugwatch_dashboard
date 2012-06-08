class PivotalDefect < Defect

  scope :bugs, where("status = 0")

end