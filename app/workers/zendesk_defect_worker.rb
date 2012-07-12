class ZendeskDefectWorker

  class << self

    def perform(secret, defect_data)
      repo_name, _ = ZendeskConfig.repo_config_by_secret(secret)
      project_id = ExceptionSourceConfig.project_id_by_repo_name(repo_name)
      Release.update!(project_id)
      ZendeskService.activity(defect_data)
    end

  end

end