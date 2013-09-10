Partreach::Application.routes.draw do

  root :to => 'static_pages#home', via: :get

  resources :signed_urls, only: :index
  resources :orders
  resources :dialogues, only: [:new, :create]
  resources :users, only: [:new, :create, :edit, :update, :show] # no index, no destroy 
  resources :sessions, only: [:new, :create, :destroy]
  resources :leads, only: [:create]
  resources :reviews, only: [:new, :create]
  resources :password_resets
  resources :suppliers, only: [:new, :create, :edit, :update, :index]

  get '/signup', to: 'orders#new'
  get '/signin', to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete
  get '/getting_started', to: 'static_pages#getting_started'
  get '/procurement', to: 'static_pages#procurement'
  get '/alpha', to: 'static_pages#procurement'
  get '/business', to: 'static_pages#procurement'
  get '/materials', to: 'static_pages#materials'
  get '/be_a_supplier', to: 'static_pages#be_a_supplier'
  get '/manipulate/:id', to: 'orders#manipulate_dialogues', as: 'manipulate'
  match 'orders/update_dialogues', to: 'orders#update_dialogues', via: :post
  get 'orders/purchase/:order/:dialogue', to: 'orders#purchase'
  get '/cto', to: 'static_pages#cto'
  get '/dialogues/new/:id', to: 'dialogues#new'
  get '/profiles/:name', to: 'profiles#supplier_profile', as: 'supplier_profile'
  get '/submit_ask/', to: 'profiles#submit_ask'
  get '/terms', to: 'static_pages#terms'
  get '/privacy', to: 'static_pages#privacy'

  get '/analytics', to: 'analytics#home', as: 'analytics_home'
  get '/analytics/rfqs', to: 'analytics#rfqs', as: 'analytics_rfqs'
  get '/analytics/suppliers', to: 'analytics#suppliers', as: 'analytics_suppliers'
  get '/analytics/emails', to: 'analytics#emails', as: 'analytics_emails'
  get '/analytics/metrics', to: 'analytics#metrics', as: 'analytics_metrics'

  #attempting hacky way to have an always-ok link for blog resources
  #get '/blog-css', to:'/blog/css/all.css'
  #get '/blog-js', to:'/blog/js/all.js'

  #goal: allow show page to post a form. seems hacky - check with someone.
  match '/orders/:id', to: 'orders#update', via: :post

  get '/examinations', to: 'suppliers#setup_examinations', as: "setup_examinations"
  match '/examinations', to: 'suppliers#submit_examinations', via: :post, as: "submit_examinations"

end
