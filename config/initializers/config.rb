AppConfig = OpenStruct.new

def get_config(config_name, default)
  config_path = File.join(Rails.root, 'config', config_name)
  if File.exists?(config_path)
    YAML.load(File.read(config_path))
  else
    default
  end
end

AppConfig.mailer = get_config("mailer.yml", {})
AppConfig.git_domains = get_config("git_domains.yml", [])
