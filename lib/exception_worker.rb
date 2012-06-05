require 'resque'
require 'exception_source'

class ExceptionWorker

  class << self

    def perform(repo_name, exception_type, exception_backtrace, deploy_sha)
      repo = Repo.find_by_name!(repo_name)
      exception_data = Bugwatch::ExceptionData.new(:type => exception_type, :backtrace => exception_backtrace)
      deploy_sha_before_last = ExceptionSource.deploy_before(deploy_sha)
      pipe_delimited_backtrace = exception_data.backtrace.map {|(file, line)| "#{file}:#{line}"}.join("|")
      mystery = Mystery.create!(exception_type: exception_data.type, backtrace: pipe_delimited_backtrace)
      Bugwatch::ExceptionTracker.discover(repo.git_analyzer, deploy_sha, exception_data, deploy_sha_before_last).each do |commit|
        c = Commit.find_by_sha!(commit.sha)
        Clue.create!(commit: c, mystery: mystery)
      end
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error e
    end

  end

end