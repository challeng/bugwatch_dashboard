class FileChangeAnalyzer

  def initialize(repo_name)
    @repo_name = repo_name
  end

  def call(commit)
    config.each do |_, group|
      files_to_email = file_changes(commit.files, group['files'])
      NotificationMailer.file_change(files_to_email, group['emails']).deliver unless files_to_email.empty?
    end
  end

  def config
    AppConfig.file_changes[@repo_name] || {}
  end

  private

  def file_changes(modified_files, files_to_watch)
    modified_files.select do |file_name|
      files_to_watch.any? {|file_pattern| File.fnmatch? file_pattern, file_name }
    end
  end

end