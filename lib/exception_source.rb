require 'nokogiri'

class ExceptionSource
  
  class << self

    def deploy_before(sha, project_id)
      sha_list = deploys(project_id).map {|deploy_data| deploy_data[:sha] }
      after(sha, sha_list).first
    end
  
    def deploys(project_id)
      _, config_data = ExceptionSourceConfig.repo_name_and_config_by_project_id(project_id)
      xml_response = get("projects/#{project_id}/deploys.xml", config_data)
      doc = Nokogiri::XML(xml_response)
      (doc / "deploy").map do |deploy_xml|
        xml_attr = lambda {|xml_doc, attr| (xml_doc / attr).text }.curry[deploy_xml]
        {
            date: xml_attr.call("created-at"),
            env: xml_attr.call("rails-env"),
            project_id: xml_attr.call("project-id"),
            sha: xml_attr.call("scm-revision"),
        }
      end
    end

    private
  
    def get(path, config, options={})
      full_path = "https://#{config["account"]}.airbrake.io/#{path}"
      options[:query] ||= {}
      options[:query][:auth_token] = config["api_key"]
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

  end

end