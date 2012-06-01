require 'resque'
require 'exception_source'

class ExceptionWorker

  class << self

    def perform(repo_name, exception_type, exception_backtrace, deploy_sha)
      repo = Repo.find_by_name!(repo_name)
      exception_data = Bugwatch::ExceptionData.new(:type => exception_type, :backtrace => exception_backtrace)
      deploy_sha_before_last = ExceptionSource.deploy_before(deploy_sha)
      Bugwatch::ExceptionTracker.discover(repo.git_analyzer, deploy_sha, exception_data, deploy_sha_before_last)
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error e
    end

  end

end