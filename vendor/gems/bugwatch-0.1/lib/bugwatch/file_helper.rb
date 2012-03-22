module Bugwatch
  module FileHelper

    def ruby_file?(file)
      file.match(/\.rb$/) && !file.match(/_spec|_steps|_test\.rb$/)
    end

  end
end