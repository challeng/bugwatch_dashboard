#!/usr/bin/env ruby

$VERBOSE = nil

require 'net/https'
require 'rubygems'
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
     req = Net::HTTP::Post.new(uri.path)
     req.set_form_data({:payload => JSON.dump(payload(input))})

     http = Net::HTTP.new(uri.host, uri.port)
     http.use_ssl = true
     http.request(req)
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