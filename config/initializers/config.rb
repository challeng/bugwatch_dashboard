AppConfig = OpenStruct.new

def mailer_config
  mailer_path = File.join(Rails.root, 'config', 'mailer.yml')
  if File.exists?(mailer_path)
    YAML.load(File.read(mailer_path))
  else
    {}
  end
end

AppConfig.mailer = mailer_config
