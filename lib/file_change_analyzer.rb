class FileChangeAnalyzer

  class << self

    def call(commit)
      config.each do |_, config_data|
        files_to_email = file_changes(commit.files, config_data['files'])
        NotificationMailer.file_change(files_to_email, config_data['emails']).deliver unless files_to_email.empty?
      end
    end

    def config
      AppConfig.file_changes
    end

    private

    def file_changes(modified_files, files_to_watch)
      modified_files.select do |file_name|
        files_to_watch.any? {|file_pattern| File.fnmatch? file_pattern, file_name }
      end
    end

  end

end