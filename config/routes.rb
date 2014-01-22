Partreach::Application.routes.draw do

  root :to => 'static_pages#home', via: :get

  resources :signed_urls, only: :index
  resources :orders, only: [:index, :show, :new, :create, :destroy]
  resources :dialogues, only: [:new, :create]
  resources :users, only: [:edit, :update, :show] # no index, no destroy 
  resources :sessions, only: [:new, :create, :destroy]
  resources :leads, only: [:new, :create, :edit, :index, :update]
  resources :reviews, only: [:new, :create]
  resources :password_resets
  resources :suppliers, only: [:new, :create, :edit, :update, :index]
  resources :communications, only: [:new, :create]
  resources :machines, only: [:new, :create, :edit, :update]
  resources :owners, only: [:create]

  get '/analytics', to: 'analytics#home', as: 'analytics_home'
  get '/analytics/rfqs', to: 'analytics#rfqs', as: 'analytics_rfqs'
  get '/analytics/suppliers', to: 'analytics#suppliers', as: 'analytics_suppliers'
  get '/analytics/emails', to: 'analytics#emails', as: 'analytics_emails'
  get '/analytics/metrics', to: 'analytics#metrics', as: 'analytics_metrics'
  get '/analytics/machines', to: 'analytics#machines', as: 'analytics_machines'
  get '/analytics/phone', to: 'analytics#phone', as: 'analytics_phone'

  get '/dialogues/new/:id', to: 'dialogues#new'
  get '/dialogues/initial_email/:id', to: 'dialogues#initial_email', as: 'dialogue_internal_email'  

  get '/examinations/:name', to: 'examinations#setup_examinations', as: "setup_examinations"
  match '/examinations', to: 'examinations#submit_examinations', via: :post, as: "submit_examinations"

  get '/guides/:name', to: 'guides#show', as: 'guide_name'

  match '/leads/admin_create', to: 'leads#admin_create', as: 'admin_create_lead', via: :post

  get '/machines/suppliers_with_machine/:machine_id', to: 'machines#suppliers_with_machine', as: 'suppliers_with_machine'

  get '/manufacturers/:manufacturer_name', to: 'profiles#manufacturer_profile', as: 'manufacturer_profile'
  get '/manufacturers/:manufacturer_name/:machine_name', to: 'profiles#machine_profile', as: 'machine_profile'
  get '/profiles/:name', to: 'profiles#supplier_profile', as: 'supplier_profile'
  get '/submit_ask/', to: 'profiles#submit_ask'
  
  get '/manipulate/:id', to: 'orders#manipulate_dialogues', as: 'manipulate'
  match '/orders/update_dialogues', to: 'orders#update_dialogues', via: :post
  get '/orders/purchase/:order/:dialogue', to: 'orders#purchase'

  get '/owners/new/:supplier_id', to: 'owners#new', as: 'new_owner'
  match '/owners/destroy/:supplier_id/:machine_id', to: 'owners#destroy', as: 'destroy_owner', via: :delete

  get '/signin', to: 'sessions#new', as: 'signin'
  match '/signout', to: 'sessions#destroy', via: :delete

  get '/signup', to: 'static_pages#questions' 
  get '/getting_started', to: 'static_pages#getting_started'
  get '/procurement', to: 'static_pages#procurement'
  get '/materials', to: 'static_pages#materials'
  get '/be_a_supplier', to: 'static_pages#be_a_supplier'
  get '/terms', to: 'static_pages#terms'
  get '/privacy', to: 'static_pages#privacy'  
  get '/questions', to: 'static_pages#questions', as: 'order_questions'
  get '/recruiting', to: 'static_pages#recruiting', as: 'recruiting'

  get 'suppliers/admin_edit/:name', to: 'suppliers#admin_edit', as: 'admin_edit'
  match 'suppliers/admin_update', to: 'suppliers#admin_update', as: 'admin_update', via: :post

end
