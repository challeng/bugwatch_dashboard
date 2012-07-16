class ExceptionSourceConfig

  class ExceptionMisconfiguration < StandardError; end

  def self.project_id_by_repo_name(repo_name)
    repo_config = config[repo_name]
    repo_config["id"] if repo_config
  end

  def self.repo_name_and_config_by_project_id(project_id)
    config.each do |(repo_name, config_data)|
      return repo_name, config_data if config_data["id"] == project_id
    end
    raise ExceptionMisconfiguration, "Airbrake project not configured. ID: #{project_id}"
  end

  private

  def self.config
    AppConfig.exceptions
  end

end