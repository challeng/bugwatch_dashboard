module Bugwatch

  class ExceptionTracker

    def self.discover(git_analyzer, begin_sha, exception_data, end_sha=nil)
      commits = git_analyzer.commits(begin_sha)
      exception_commit = commits.first
      exception_sources = exception_data.backtrace.map {|(file, line)| exception_commit.identify(file, line) }
      commits_in_range(commits, end_sha).select do |commit|
        diffs(commit, exception_data).any? {|diff|
          exception_sources.any? {|exception_source| touched_exception?(diff.modifications, exception_source) } }
      end
    end

    private

    def self.commits_in_range(commits, end_sha)
      commits.take_while do |commit|
        commit.sha != end_sha
      end
    end

    def self.diffs(commit, exception_data)
      files = exception_data.backtrace.map(&:first)
      commit.diffs.select do |diff|
        files.include? diff.path
      end
    end

    def self.touched_exception?(modifications, exception_source)
      exception_source.any? { |klass, _methods|
        modifications[klass] && _methods.any? { |func| modifications[klass].include? func } }
    end

  end

end