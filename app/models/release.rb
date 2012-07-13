require 'exception_source'

class Release < ActiveRecord::Base
  belongs_to :repo

  scope :production, where(:env => "production")

  def self.update!(project_id)
    repo_name, _ = ExceptionSourceConfig.repo_name_and_config_by_project_id(project_id)
    repo = Repo.find_by_name! repo_name
    ExceptionSource.deploys(project_id).each do |deploy|
      Release.find_or_create_by_deploy_date_and_repo_id(deploy[:date], repo.id, sha: deploy[:sha], env: deploy[:env])
    end
  rescue ActiveRecord::RecordNotFound
    nil
  end

end
