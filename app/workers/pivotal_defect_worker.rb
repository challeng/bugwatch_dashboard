require 'config/pivotal_config'

class PivotalDefectWorker < DefectWorker

  class << self

    def service(activity_data)
      PivotalService.activity activity_data
    end

    private

    def get_project_id(pivotal_project_id)
      repo_name, _ = PivotalConfig.repo_name_and_token_by_project_id(pivotal_project_id)
      ExceptionSourceConfig.project_id_by_repo_name(repo_name)
    end

  end

end