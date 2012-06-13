class FileChangeAnalyzer

  class << self

    def call(commit)
      config_data_list.each_value do |config_data|
        file_change_notifications(commit.files, config_data)
      end
    end

    def config_data_list
      AppConfig.file_changes
    end

    def file_change_notifications(file_names, config_data)
      files_to_watch = config_data['files']

      files_to_email = file_names.select do |file_name|
        files_to_watch.include? file_name
      end


      NotificationMailer.file_change(files_to_email, config_data['emails']).deliver unless files_to_email.empty?
    end

  end

end