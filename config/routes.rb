require 'commit_hook'

BugwatchDashboard::Application.routes.draw do

  resources :subscription

  match '/hook', :to => CommitHook
  resource :sessions
  resources :repo do
    member { get :alerts }
  end

  resources :alerts

  root :to => "repo#index"

end
