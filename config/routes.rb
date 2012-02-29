require 'commit_hook'

BugwatchDashboard::Application.routes.draw do

  resources :subscription

  match '/hook', :to => CommitHook
  resource :sessions
  resources :repo do
    member { get :alerts }
  end

  root :to => "repo#index"

end
