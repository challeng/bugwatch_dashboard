require 'commit_hook'

BugwatchDashboard::Application.routes.draw do

  resources :subscription

  match '/hook', :to => CommitHook
  resource :session
  resources :repos do
    resources :alerts
  end


  root :to => "repos#index"

end
