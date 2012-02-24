require 'commit_hook'

BugwatchDashboard::Application.routes.draw do

  match '/hook', :to => CommitHook
  resource :sessions

  root :to => "application#index"

end
