AppConfig = OpenStruct.new

AppConfig.mailer = YAML.load(File.read(File.join(Rails.root, 'config', 'mailer.yml')))