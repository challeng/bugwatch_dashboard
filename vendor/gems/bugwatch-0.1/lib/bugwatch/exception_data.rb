module Bugwatch

  class ExceptionData

    attr_reader :type, :backtrace

    def initialize(opts={})
      @type = opts[:type]
      @backtrace = opts[:backtrace] || []
    end

    def file
      file, _ = backtrace.first
      file
    end

    def line
      _, line = backtrace.first
      line.to_i if line
    end

  end

end