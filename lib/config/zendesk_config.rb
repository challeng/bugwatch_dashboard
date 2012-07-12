class ZendeskConfig

  def self.repo_config_by_secret(secret)
    config.each do |repo_name, config_data|
      return repo_name, config_data if config_data["secret"] == secret
    end
    nil
  end

  private

  def self.config
    AppConfig.zendesk
  end

end