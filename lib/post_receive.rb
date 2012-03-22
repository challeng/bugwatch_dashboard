#!/usr/bin/env ruby

require 'net/http'
require 'json'

class PostReceive
  class << self

    def payload(input)
      old_revision, new_revision, ref = input.split(" ")
      revisions = `git rev-list --first-parent #{new_revision}`
      new_revisions = revisions.split("\n").take_while {|rev| rev != old_revision }.reverse

      {
          :ref => ref,
          :repository => {:name => repo, :url => repo_url},
          :commits => new_revisions.map{|rev| {:id => rev} }
      }
    end

    def post(input, hook_url)
      uri = URI(hook_url)
      Net::HTTP.post_form(uri, {:payload => JSON.dump(payload(input))})
    end

    private

    def git_root
      Dir.pwd.gsub(%r|\.git(/.*)?$|, '.git')
    end

    def repo
      File.basename(git_root, ".git")
    end

    def repo_url
      "git:#{repo}.git"
    end

  end
end

if $0 == __FILE__
  hook_url = nil
  raise Exception, "need to supply a hook url" unless hook_url
  PostReceive.post(STDIN.read, hook_url)
end