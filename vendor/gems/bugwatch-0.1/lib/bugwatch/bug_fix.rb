require 'date'
require 'active_support/hash_with_indifferent_access'

module Bugwatch

  class BugFix

    attr_reader :file, :sha, :klass, :function

    def initialize(opts={})
      opts.symbolize_keys!
      @file = opts[:file]
      @date = opts[:date]
      @sha = opts[:sha]
      @klass = opts[:klass]
      @function = opts[:function]
    end

    def date
      if @date.is_a?(String)
        DateTime.parse(@date)
      else
        @date
      end
    end

    def score
      relevance = 1 - ((DateTime.now - self.date).to_f / Time.now.to_f)
      (1 / (1 + Math.exp((-12 * relevance) + 12)))
    end

    def to_json
      {:file => file, :sha => sha, :date => date, :klass => klass, :function => function}
    end

  end

end