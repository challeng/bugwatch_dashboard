class ZendeskDefectWorker < DefectWorker

  class << self

    def service(defect_data)
      ZendeskService.activity(defect_data)
    end

    private

    def get_project_id(secret)
      repo_name, _ = ZendeskConfig.repo_config_by_secret(secret)
      ExceptionSourceConfig.project_id_by_repo_name(repo_name)
    end

  end

end