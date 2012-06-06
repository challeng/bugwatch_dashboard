require 'hooks/commit_hook'
require 'hooks/defect_hook'

BugwatchDashboard::Application.routes.draw do

  resources :subscription

  match '/hook', :to => CommitHook
  match '/defect', :to => DefectHook
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
      match '/fixcache_graph' => :fixcache_graph
      get :subscription
    end
  end


  root :to => "repos#index"

end
