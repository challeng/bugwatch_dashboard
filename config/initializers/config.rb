require 'ostruct'
require 'config/exception_source_config'
require 'config/zendesk_config'

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
AppConfig.file_changes = get_config("file_change.yml", {})
AppConfig.exceptions = get_config("services/exceptions.yml", {})
AppConfig.pivotal = get_config("services/pivotal.yml", {})
AppConfig.zendesk = get_config("services/zendesk.yml", {})

if defined? ActionMailer
  ActionMailer::Base.smtp_settings = {
    :address              => "smtp.gmail.com",
    :port                 => 587,
    :domain               => AppConfig.mailer["domain"],
    :user_name            => AppConfig.mailer["user_name"],
    :password             => Base64.decode64(AppConfig.mailer["password"] || ""),
    :authentication       => "plain",
    :enable_starttls_auto => true
  }
  ActionMailer::Base.default_url_options[:host] = AppConfig.mailer["host"] || "localhost:3000"
end

