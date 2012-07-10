class Release < ActiveRecord::Base
  belongs_to :repo

  def self.update!(project_id)
    ExceptionSource.deploys(project_id).each do |deploy|
      Release.find_or_create_by_sha(deploy[:sha], deploy_date: deploy[:date], env: deploy[:env])
    end
  end

end
