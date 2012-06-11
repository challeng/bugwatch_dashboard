module Bugwatch

  class Repo
    def initialize(url)
      @url = url
    end

    def commit(sha)
      grit_repo.commit(sha)
    end

    def walk(sha, &action)
      rugged_repo.walk(sha, action)
    end

    private

    def grit_repo
      @grit_repo ||= Grit::Repo.new(@url)
    end

    def rugged_repo
      @rugged_repo ||= Rugged::Repository.new(@url)
    end

  end

end