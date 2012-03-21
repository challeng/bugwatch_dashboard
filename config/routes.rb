require 'commit_hook'

BugwatchDashboard::Application.routes.draw do

  resources :subscription

  match '/hook', :to => CommitHook
  resource :sessions
  resources :repos do
    resources :alerts
    resources :tags, :only => [:index, :show]
    controller :tags do
      post :diff
    end
    member do
      match '/commit/:sha' => :commit, :as => :commit
      match '/file/*filename' => :file, :as => :file
      get :subscription
    end
  end


  root :to => "repos#index"

end
