RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  # only allow admin users
  config.authorize_with do |controller|
    redirect_to main_app.root_path unless current_user.try(:admin?)
  end

  # exclude irrelevant modules and model classes from auto-discovery
  config.excluded_models = 
    ["Admin", "Crawlers", "DataAnalysis", "DataEntry", "Order::OrderColumn", "Order::OrderTransferor", "RakeHelper"]

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
