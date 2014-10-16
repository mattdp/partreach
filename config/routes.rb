Partreach::Application.routes.draw do

  root :to => 'static_pages#home', via: :get

  get '/analytics', to: 'analytics#home', as: 'analytics_home'
  get '/analytics/rfqs', to: 'analytics#rfqs', as: 'analytics_rfqs'
  get '/analytics/suppliers', to: 'analytics#suppliers', as: 'analytics_suppliers'
  get '/analytics/emails', to: 'analytics#emails', as: 'analytics_emails'
  get '/analytics/invoicing', to: 'analytics#invoicing', as: 'analytics_invoicing'
  get '/analytics/metrics', to: 'analytics#metrics', as: 'analytics_metrics'
  get '/analytics/machines', to: 'analytics#machines', as: 'analytics_machines'
  get '/analytics/phone', to: 'analytics#phone', as: 'analytics_phone'
  get '/analytics/web_search_results', to: 'analytics#web_search_results', as: 'analytics_web_search_results'

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

  get '/experiments/sde', to: 'experiments#sde', as: "experiments_sde"
  get '/experiments/sla', to: 'experiments#sla', as: "experiments_sla"
  get '/experiments/ultem', to: 'experiments#ultem', as: "experiments_ultem"

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
  match '/leads/admin_create', to: 'leads#admin_create', as: 'admin_create_lead', via: :post

  resources :machines, only: [:new, :create, :edit, :update]
  get '/machines/suppliers_with_machine/:machine_id', to: 'machines#suppliers_with_machine', as: 'suppliers_with_machine'

  get '/manufacturers/:manufacturer_name', to: 'profiles#manufacturer_profile', as: 'manufacturer_profile'
  get '/manufacturers/:manufacturer_name/:machine_name', to: 'profiles#machine_profile', as: 'machine_profile'
  get '/profiles/:supplier_name', to: 'profiles#supplier_profile_redirect', as: 'supplier_profile'
  get '/submit_ask/', to: 'profiles#submit_ask'
  
  resources :orders, only: [:index, :show, :new, :create, :destroy]
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

  resources :password_resets

  match '/parts/create_with_external', to: 'parts#create_with_external', via: :post, as: 'create_with_external'

  resources :parts, only: [:create]

  resources :reviews, only: [:new, :create]

  resources :sessions, only: [:new, :create, :destroy]
  get '/signin', to: 'sessions#new', as: 'signin'
  match '/signout', to: 'sessions#destroy', via: :delete

  get '/signup', to: 'orders#new' 
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
