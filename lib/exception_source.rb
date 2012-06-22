require 'nokogiri'

class ExceptionSource

  class ExceptionMisconfiguration < Exception; end

  def self.deploy_before(sha, opts={})
    xml_response = self.get("/projects/1111/deploys.xml")
    doc = Nokogiri::XML(xml_response)
    sha_list = (doc / "scm-revision").map(&:text)
    sha_list.drop_while {|deploy_sha| deploy_sha != sha }.drop(1).first
  end

  def self.get(path, options={}, &block)
    full_path = base_uri + path
    options[:query] ||= {}
    options[:query][:api_key] = api_key
    HTTParty.get(full_path, options, &block)
  end

  private

  def self.base_uri
    account = airbrake_config["account"]
    "http://#{account}.airbrake.io" if account
  end

  def self.api_key
    airbrake_config["api_key"]
  end

  def self.airbrake_config
    config = AppConfig.exceptions || {}
    raise ExceptionMisconfiguration, "You must configure an airbrake service as an exception source" unless config["airbrake"]
    config["airbrake"]
  end

end