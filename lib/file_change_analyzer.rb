class FileChangeAnalyzer

	def call(commit)
		file_names = commit.files # array of modified files
		files_to_email = []

		config_data = YAML.load_file(file_change.yml)
		files_to_watch = config_data['files_to_watch']

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
		NotificationMailer.file_change(files_to_email).deliver

	end

end