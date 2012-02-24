require 'commit_hook'

BugwatchDashboard::Application.routes.draw do

  match '/hook', :to => CommitHook
  resource :sessions
  resources :repo

  root :to => "repo#index"

end
