require 'nokogiri'

class ExceptionSource

  class ExceptionMisconfiguration < Exception; end
  
  class << self

    def deploy_before(sha, project_id)
      sha_list = (deploys(project_id) / "scm-revision").map(&:text)
      after(sha, sha_list).first
    end
  
    def deploys(project_id)
      _, config_data = repo_name_and_config_by_project_id(project_id)
      xml_response = get("projects/#{project_id}/deploys.xml", config_data)
      Nokogiri::XML(xml_response)
    end

    private
  
    def get(path, config, options={})
      full_path = "http://#{config["account"]}.airbrake.io/#{path}"
      options[:query] ||= {}
      options[:query][:api_key] = config["api_key"]
      HTTParty.get(full_path, options).body
    end
  
    def base_uri
      account = config["account"]
      "http://#{account}.airbrake.io" if account
    end
  
    def config
      AppConfig.exceptions
    end
  
    def after(needle, haystack)
      Enumerator.new do |y|
        found = false
        haystack.each do |item|
          y << item if found
          found = true if item == needle
        end
      end
    end

    def repo_name_and_config_by_project_id(project_id)
      config.each do |(repo_name, config_data)|
        return repo_name, config_data if config_data["id"] == project_id
      end
      raise ExceptionMisconfiguration, "Airbrake project not configured. ID: #{project_id}"
    end


  end

end