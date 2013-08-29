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
  get 'orders/update_dialogues', to: 'orders#update_dialogues'
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

  #goal: allow show page to post a form. seems hacky - check with someone.
  match '/orders/:id', to: 'orders#update', via: :post

  get '/examinations', to: 'suppliers#setup_examinations', as: "setup_examinations"
  match '/examinations', to: 'suppliers#submit_examinations', via: :post, as: "submit_examinations"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
