class FileChangeAnalyzer

  class << self

    def call(commit)
      #return if AppConfig.file_changes = {}

      #file_names = commit.files # array of modified files

      config_data_list.each_value do |config_data|
        file_change_notifications(commit.files, config_data)
      end
    end

    def config_data_list
      #hash of all the groups
      AppConfig.file_changes
    end

    def file_change_notifications(file_names, config_data)
      files_to_watch = config_data['files']
      files_to_email = []

      #loop through each file changed in commit
      file_names.each do |file_name|
        #check it against each name of a file we care about
        files_to_watch.each do |watched_file|
          if file_name.eql? watched_file
            files_to_email << file_name
          end
        end
      end

      #send email here
      if !files_to_email.empty?
        NotificationMailer.file_change(files_to_email, config_data['emails']).deliver
      end
    end

  end

end