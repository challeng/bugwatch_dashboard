require 'commit_hook'

BugwatchDashboard::Application.routes.draw do

  match '/hook', :to => CommitHook

end
