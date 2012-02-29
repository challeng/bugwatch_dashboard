require 'commit_hook'

BugwatchDashboard::Application.routes.draw do

  resources :subscription

  match '/hook', :to => CommitHook
  resource :sessions
  resources :repos do
    resources :alerts
  end


  root :to => "repos#index"

end
