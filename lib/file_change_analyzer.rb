class FileChangeAnalyzer

  attr_reader :repo

  def initialize(repo)
    @repo = repo
  end

  def call(commit)
    config.each do |_, group|

      next if ignore_group?(Array(group['ignore']), commit.grit.committer.email)

      files_to_email = file_changes(commit.files, group['files'])
      diffs = commit.diffs.select {|diff| files_to_email.include? diff.path }
      diffs_string = diffs.map(&:diff).join("\n")

      NotificationMailer.file_change(files_to_email, group['emails'], commit, @repo, diffs_string).deliver unless files_to_email.empty?
    end
  end

  def ignore_group?(committers_to_ignore, committer_email)
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