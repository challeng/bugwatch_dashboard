require 'hooks/commit_hook'
require 'hooks/zendesk_hook'
require 'hooks/pivotal_hook'

BugwatchDashboard::Application.routes.draw do

  resources :subscription

  match '/hook', :to => CommitHook
  match '/zendesk', :to => ZendeskHook
  match '/pivotal', :to => PivotalHook

  resource :sessions
  resources :repos do
    resources :alerts
    resources :tags, :only => [:index, :show]
    resources :defects, :only => [:index]
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
