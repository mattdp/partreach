Partreach::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root :to => 'static_pages#home', via: :get

  get '/factory-survey', to: redirect('http://fluidsurveys.com/surveys/supplybetter/factory-survey/', status: 302)

  get '/analytics', to: 'analytics#home', as: 'analytics_home'
  get '/analytics/rfqs', to: 'analytics#rfqs', as: 'analytics_rfqs'
  get '/analytics/suppliers', to: 'analytics#suppliers', as: 'analytics_suppliers'
  get '/analytics/emails', to: 'analytics#emails', as: 'analytics_emails'
  get '/analytics/invoicing', to: 'analytics#invoicing', as: 'analytics_invoicing'
  get '/analytics/metrics', to: 'analytics#metrics', as: 'analytics_metrics'
  get '/analytics/machines', to: 'analytics#machines', as: 'analytics_machines'
  get '/analytics/phone', to: 'analytics#phone', as: 'analytics_phone'
  get '/analytics/web_search_results', to: 'analytics#web_search_results', as: 'analytics_web_search_results'

  resources :comments, only: [:create, :edit, :update]
  get '/comments/new_comment/:provider_id', to: 'comments#new_comment', as: 'new_comment'
  get '/comments/new_factory_visit_comment/:provider_id', to: 'comments#new_factory_visit_comment', as: 'new_factory_visit_comment'
  get '/comments/new_purchase_order_comment/:provider_id', to: 'comments#new_purchase_order_comment', as: 'new_purchase_order_comment'
  get '/comments/edit/comments/:id/edit/:flavor', to: 'comments#edit', as: 'comments_edit_with_status_long_mistake' #delete after July 15 2015, allowing time for the emails at Synapse with this route to be used or ignored
  get '/comments/:id/edit/:flavor', to: 'comments#edit', as: 'comments_edit_with_status'
  get '/comments/later/:id', to: 'comments#later', as: 'comments_later'
  get '/comments/request_for_review/:id', to: 'comments#request_for_review', as: 'comments_request_for_review'

  resources :comment_ratings, only: [:create]
  
  resources :communications, only: [:new, :create]

  resources :dialogues, only: [:new, :create, :destroy]
  get '/dialogues/new/:id', to: 'dialogues#new'
  get '/dialogues/initial_email/:id', to: 'dialogues#initial_email', as: 'dialogue_initial_email'
  get '/dialogues/edit_rfq_close_email/:id', to: 'dialogues#edit_rfq_close_email', as: 'dialogue_edit_rfq_close_email'
  get '/dialogues/generate_rfq_close_email', to: 'dialogues#generate_rfq_close_email', as: 'dialogue_generate_rfq_close_email'
  get '/dialogues/review_rfq_close_email/:id', to: 'dialogues#review_rfq_close_email', as: 'dialogue_review_rfq_close_email'
  match '/dialogues/update_rfq_close_email', to: 'dialogues#update_rfq_close_email', as: 'dialogue_update_rfq_close_email', via: :post
  match '/dialogues/update_email_snippet', to: 'dialogues#update_email_snippet', as: 'dialogue_update_email_snippet', via: :post
  match '/dialogues/send_initial_email/:id', to: 'dialogues#send_initial_email', as: 'dialogue_send_initial_email', via: :post
  match '/dialogues/send_rfq_close_email/:id', to: 'dialogues#send_rfq_close_email', as: 'dialogue_send_rfq_close_email', via: :post

  get '/examinations/:name', to: 'examinations#setup_examinations', as: "setup_examinations"
  match '/examinations', to: 'examinations#submit_examinations', via: :post, as: "submit_examinations"

  get '/experiments/ultem', to: 'experiments#ultem', as: "experiments_ultem"
  get '/experiments/sls_vs_fdm', to: 'experiments#sls_vs_fdm', as: "experiments_sls_vs_fdm"

  get '/guides/:country/:state/:tag', to: redirect("/suppliers/%{country}/%{state}/%{tag}")
  get '/guides/:country/:tag', to: redirect("/suppliers/%{country}/all/%{tag}")
  get '/guides/:name', to: redirect {|params, req| 
    cst = params[:name].match(/(\w+)-(\w+)-(\w+)/)
    ct = params[:name].match(/(\w+)-(\w+)/)
    if cst.present?
      "/suppliers/#{cst[1]}/#{cst[2]}/#{cst[3]}"
    elsif ct.present?
      "/suppliers/#{ct[1]}/all/#{ct[2]}"
    else
      "/suppliers/#{params[:name]}"
    end
    }

  resources :leads, only: [:new, :create, :edit, :index, :update]
  match '/leads/blog_create', to: 'leads#blog_create', as: 'blog_create_lead', via: :post
  match '/leads/admin_create', to: 'leads#admin_create', as: 'admin_create_lead', via: :post

  resources :machines, only: [:new, :create, :edit, :update]
  get '/machines/suppliers_with_machine/:machine_id', to: 'machines#suppliers_with_machine', as: 'suppliers_with_machine'

  get '/manufacturers/:manufacturer_name', to: 'profiles#manufacturer_profile', as: 'manufacturer_profile'
  get '/manufacturers/:manufacturer_name/:machine_name', to: 'profiles#machine_profile', as: 'machine_profile'
  get '/profiles/:supplier_name', to: 'profiles#supplier_profile_redirect', as: 'supplier_profile'
  get '/submit_ask/', to: 'profiles#submit_ask'
  
  resources :orders, only: [:index, :show, :new, :create, :destroy]
  get '/orders/view/:id/:view_token', to: 'orders#show', as: 'view_order'
  resources :transfer_orders, only: [:create]
  get '/manipulate/:id', to: 'orders#manipulate_dialogues', as: 'manipulate'
  get '/parts/:id', to: 'orders#manipulate_parts', as: 'manipulate_parts'
  match '/orders/update_dialogues', to: 'orders#update_dialogues', via: :post
  match '/orders/update_parts', to: 'orders#update_parts', via: :patch
  get '/orders/purchase/:order/:dialogue', to: 'orders#purchase'
  get '/orders/initial_email_edit/:id', to: 'orders#initial_email_edit', as: 'initial_email_edit'
  match '/orders/initial_email_update', to: 'orders#initial_email_update', as: 'initial_email_update', via: :post

  resources :order_groups, only: [:new, :create, :edit, :update]

  resources :owners, only: [:create]
  get '/owners/new/:supplier_id', to: 'owners#new', as: 'new_owner'
  match '/owners/destroy/:supplier_id/:machine_id', to: 'owners#destroy', as: 'destroy_owner', via: :delete

  resources :password_resets, only: [:new, :create]

  resources :parts, only: [:create]

  resources :providers, only: [:new, :create, :edit]
  get '/providers/new/:event_name', to: 'providers#new', as: 'new_provider_with_event'
  get '/providers/:id/edit/:event_name/', to: 'providers#edit', as: 'edit_provider_with_event'
  post 'providers/create_tag', to: 'providers#create_tag', as: 'create_provider_tag'
  match 'providers/:id', to: 'providers#update', as: 'provider', via: :post
  get '/teams/signin', to: redirect('/signin')
  get '/teams', to: 'providers#index', as: "teams_index"
  get '/teams/hax', to: 'providers#index'
  get '/teams/providers/:name_for_link', to: 'providers#profile', as: "teams_profile"
  get '/teams/hax/providers/:name_for_link', to: 'providers#profile'
  get '/teams/suggested_edit/:clicked', to: 'providers#suggested_edit', as: "teams_suggested_edit"
  post '/provider/upload_photo', to: 'providers#upload_photo'
  get '/teams/providers/search/results', to: 'providers#search_results', as: 'providers_search_results'

  resources :purchase_orders, only: [:index]
  get '/purchase_orders/email_sent/:id/:after_this_email_count', to: 'purchase_orders#email_sent', as: 'purchase_orders_email_sent'

  resources :sessions, only: [:new, :create, :destroy, :edit, :update]
  get '/signin', to: 'sessions#new', as: 'signin'
  match '/signout', to: 'sessions#destroy', via: :delete
  get '/reset_password/:id', to: 'sessions#internal_edit', as: "sessions_internal_edit"
  match '/reset_password', to: 'sessions#internal_update', as: "sessions_internal_update", via: :patch

  get '/signup', to: 'orders#new' 
  get '/enterprise', to: 'static_pages#enterprise' #enterprise.html.erb L21 is hardlinked to this, change if you change the route
  get '/getting_started', to: 'static_pages#getting_started'
  get '/procurement', to: 'static_pages#procurement'
  get '/materials', to: 'static_pages#materials'
  get '/be_a_supplier', to: 'static_pages#be_a_supplier'
  get '/testimonials', to: 'static_pages#testimonials'
  get '/terms', to: 'static_pages#terms'
  get '/privacy', to: 'static_pages#privacy'  
  get '/questions', to: redirect('/orders/new')
  get '/recruiting', to: 'static_pages#recruiting', as: 'recruiting'

  resources :suppliers, only: [:new, :create, :edit, :update, :index]
  get 'suppliers/admin_edit/:name', to: 'suppliers#admin_edit', as: 'admin_edit'
  match 'suppliers/admin_update', to: 'suppliers#admin_update', as: 'admin_update', via: :post
  get 'suppliers/:country', to: 'suppliers#state_index', as: 'state_index'
  get 'suppliers/:country/:state', to: 'suppliers#tag_index', as: 'tag_index'
  get 'suppliers/:country/:state/:term', to: 'suppliers#lookup', as: 'lookup'

  resources :tags, only: [:show, :new, :create, :edit, :update, :index] do
    resources :tag_relationships, only: [:index, :create]
  end
  resources :tag_relationship_types, only: [:index]
  get '/tags/:id/related', to: 'tags#related_tags', as: 'related_tags'

  resources :users, only: [:edit, :update, :show] # no index, no destroy 

  resources :web_search_items, except: [:show]
  post '/web_search_items/upload', to: 'web_search_items#upload'
  post '/web_search_items/run_immediate', to: 'web_search_items#run_immediate'

end
