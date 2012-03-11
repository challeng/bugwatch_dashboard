require 'commit_hook'

BugwatchDashboard::Application.routes.draw do

  resources :subscription

  match '/hook', :to => CommitHook
  resource :sessions
  resources :repos do
    resources :alerts
    member do
      match '/commit/:sha' => :commit, :as => :commit
    end
  end


  root :to => "repos#index"

end
