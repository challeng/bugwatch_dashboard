require File.expand_path('../bugwatch', __FILE__)
require File.expand_path('../mailer', __FILE__)
require 'grit'
require 'json'
require 'resque'
require 'pony'
require 'base64'

class PostReceive

  class << self

    def perform(repository_name, repository_url, commit_sha)
      git_fix_cache = Bugwatch::GitFixCache.new(repository_name, repository_url)
      commit = git_fix_cache.repo.commit(commit_sha)
      git_fix_cache.add(commit)
      git_fix_cache.write_bug_cache
      feedback = get_violations(git_fix_cache.cache.hot_spots, commit)
      Mailer.send_feedback(feedback, commit) unless feedback.empty?
    end

    def get_violations(hot_spots, commit)
      commit_files = commit.stats.files.map(&:first)
      hot_spots = hot_spots.select { |hot_spot| commit_files.include?(hot_spot.file) }
      diffs = commit.diffs.select {|diff| hot_spots.map(&:file).include?(diff.b_path) }
      hot_spots.sort_by(&:file).zip(diffs.sort_by(&:b_path)).each_with_object({}) do |(hot_spot, diff), hsh|
        violations = Bugwatch::DiffParser.parse_class_and_functions(diff).flat_map do |(klass, methods)|
          hot_spot.bug_fixes.select {|bug_fix| bug_fix.klass == klass && methods.include?(bug_fix.function) }
        end
        hsh[hot_spot.file] = violations
      end
    end

  end

end