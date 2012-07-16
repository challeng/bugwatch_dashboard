require 'config/pivotal_config'

class PivotalDefectWorker

  def self.perform(pivotal_project_id, activity_data)
    begin
      repo_name, _ = PivotalConfig.repo_name_and_token_by_project_id(pivotal_project_id)
      exception_source_project_id = ExceptionSourceConfig.project_id_by_repo_name(repo_name)
      Release.update! exception_source_project_id
      PivotalService.activity activity_data
    rescue => e
      Rails.logger.error e
    end
  end

end