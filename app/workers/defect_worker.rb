class DefectWorker

  @queue = :defects

  class << self

    def perform(*args)
      begin
        Release.update! get_project_id(args.shift)
        service(*args)
      rescue => e
        Rails.logger.error e
      end
    end

    def service(*args)
      raise NotImplementedError
    end

    private

    def get_project_id(identifier)
      raise NotImplementedError
    end

  end

end