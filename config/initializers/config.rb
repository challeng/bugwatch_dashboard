AppConfig = OpenStruct.new

mailer_path = File.join(Rails.root, 'config', 'mailer.yml')
AppConfig.mailer = YAML.load(File.read(mailer_path)) if File.exists?(mailer_path)