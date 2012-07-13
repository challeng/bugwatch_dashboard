class PivotalConfig

  def self.repo_name_and_token_by_project_id(project_id)
    config.each do |(repo_name, config_data)|
      project_config_data = config_data.find {|data| data["id"] == project_id}
      return repo_name, project_config_data["token"] if project_config_data
    end
    nil
  end

  def self.config
    AppConfig.pivotal
  end

end