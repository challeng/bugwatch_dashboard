class FileChangeAnalyzer

  attr_reader :repo

  def initialize(repo)
    @repo = repo
  end

  def call(commit)
    config.each do |_, group|

      unless(bad_committer? group['committers_to_ignore'] || [], commit.grit.committer.email )
        files_to_email = file_changes(commit.files, group['files'])
        NotificationMailer.file_change(files_to_email, group['emails'], commit, @repo).deliver unless files_to_email.empty?
      end

    end
  end

  def bad_committer?(committers_to_ignore = [], committer_email)
    committers_to_ignore.include? committer_email
  end

  def config
    AppConfig.file_changes[@repo.name] || {}
  end

  private

  def file_changes(modified_files, files_to_watch)
    modified_files.select do |file_name|
      files_to_watch.any? {|file_pattern| File.fnmatch? file_pattern, file_name }
    end
  end

end