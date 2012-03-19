require 'commit_hook'

BugwatchDashboard::Application.routes.draw do

  resources :subscription

  match '/hook', :to => CommitHook
  resource :sessions
  resources :repos do
    resources :alerts
    resources :tags do
      member do
        match '/diff/:diff_id' => :diff, :as => :diff
      end
    end
    member do
      match '/commit/:sha' => :commit, :as => :commit
      match '/file/*filename' => :file, :as => :file
    end
  end


  root :to => "repos#index"

end
