class FileChangeAnalyzer

	def call(commit)
		file_names = commit.files # array of modified files

		config_data_list.each do |config_data|
			file_change_notifications(file_names, config_data)
		end
	end

	def config_data_list
		Dir["config/file_changes/*.yml"].map {|file_name| YAML.load_file(file_name) } 
	end

	def file_change_notifications(file_names, config_data)
		files_to_watch = config_data['files_to_watch']
		files_to_email = []

		#loop through each file changed in commit
		file_names.each do |file_name|
			#check it against each name of a file we care about
			files_to_watch.each do |watched_file|
				if file_name.include? watched_file
					files_to_email << file_name
				end
			end
		end

		#send email here
		NotificationMailer.file_change(files_to_email, config_data).deliver
	end

end