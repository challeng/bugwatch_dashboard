class FileChangeAnalyzer

	def call(commit)
		file_names = commit.files # array of modified files
		files_to_email = []
		files_we_want = ['campaign.rb']

		#loop through each file changed in commit
		file_names.each do |file_name|
			#check it against each name of a file we care about
			files_we_want.each do |file_we_want|
				if file_name.include? file_we_want
					files_to_email << file_we_want
				end
			end


		end

		#send email here
		NotificationMailer.file_change(files_to_email).deliver

	end

end