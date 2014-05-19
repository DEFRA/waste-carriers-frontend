Registrations::Application.routes.draw do
  #scope '(:locale)' do
	  devise_for :users, :skip => [:registrations], :controllers => { :registrations => "devise/registrations", :confirmations => "confirmations"}
	    as :user do
	      get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'    
	      put 'users/:id' => 'devise/registrations#update', :as => 'user_registration'            
	    end

	  devise_for :agency_users, :skip => [:registrations], :controllers => { :registrations => "devise/registrations"}
	    as :agency_user do
	      get 'agency_users/edit' => 'devise/registrations#edit', :as => 'edit_agency_user_registration'    
	      put 'agency_users/:id' => 'devise/registrations#update', :as => 'agency_user_registration'            
	    end

	  devise_for :admins, :skip => [:registrations], :controllers => { :registrations => "devise/registrations"}
	    as :admin do
	      get 'admins/edit' => 'devise/registrations#edit', :as => 'edit_admin_registration'    
	      put 'admins/:id' => 'devise/registrations#update', :as => 'admin_registration'            
	    end

	  root :to => "home#index"

	  get "home/index"
	  get "user/:id/registrations" => 'registrations#userRegistrations', :as => :userRegistrations
	  
	  get "registrations/find" => 'discovers#new', :via => [:get, :post], :as => :find
	  
	  # Add routing for Public Search
	  get "registrations/search" => 'registrations#publicSearch', :via => [:get], :as => :public
	  
	  #get "registrations/start" => 'registrations#start', :as => :start
	  get "registrations/:id/finish" => 'registrations#finish', :as => :finish
	  match "registrations/:id/ncccedit" => 'registrations#ncccedit', :via => [:get], :as => :ncccedit
	  match "registrations/:id/ncccedit" => 'registrations#ncccupdate', :via => [:post,:put,:patch]
	  get "registrations/version" => 'registrations#version', :via => [:get], :as => :version
	  get "registrations/data-protection" => 'registrations#dataProtection', :via => [:get], :as => :dataProtection
	  
	  # Add routing for confirm delete registration
	  get "registrations/:id/confirmDelete" => 'registrations#confirmDelete', :via => [:get], :as => :confirmDelete
	  
	  # Add a new route for the print view
	  match "registrations/:id/print" => 'registrations#print', :via => [:get,:patch], :as => :print
	 
	  # Registration urls - Smart answers
    match "your-registration/business-type" => 'registrations#newBusinessType', :via => [:get], :as => :newBusinessType
    match "your-registration/business-type" => 'registrations#updateNewBusinessType', :via => [:post,:put,:patch]

    match "your-registration/no-registration" => 'registrations#newNoRegistration', :via => [:get], :as => :newNoRegistration
    match "your-registration/no-registration" => 'registrations#updateNewNoRegistration', :via => [:post,:put,:patch]

    match "your-registration/other-businesses" => 'registrations#newOtherBusinesses', :via => [:get], :as => :newOtherBusinesses
    match "your-registration/other-businesses" => 'registrations#updateNewOtherBusinesses', :via => [:post,:put,:patch]

    match "your-registration/service-provided" => 'registrations#newServiceProvided', :via => [:get], :as => :newServiceProvided
    match "your-registration/service-provided" => 'registrations#updateNewServiceProvided', :via => [:post,:put,:patch]

    match "your-registration/construction-demolition" => 'registrations#newConstructionDemolition', :via => [:get], :as => :newConstructionDemolition
    match "your-registration/construction-demolition" => 'registrations#updateNewConstructionDemolition', :via => [:post,:put,:patch]

    match "your-registration/only-deal-with" => 'registrations#newOnlyDealWith', :via => [:get], :as => :newOnlyDealWith
    match "your-registration/only-deal-with" => 'registrations#updateNewOnlyDealWith', :via => [:post,:put,:patch]

    # Registration urls - Lower tier
	  match "your-registration/business-details" => 'registrations#newBusinessDetails', :via => [:get], :as => :newBusinessDetails
	  match "your-registration/business-details" => 'registrations#updateNewBusinessDetails', :via => [:post,:put,:patch]
	  
	  match "your-registration/contact-details" => 'registrations#newContactDetails', :via => [:get], :as => :newContact
	  match "your-registration/contact-details" => 'registrations#updateNewContactDetails', :via => [:post,:put,:patch]
	  
	  match "your-registration/confirmation" => 'registrations#newConfirmation', :via => [:get], :as => :newConfirmation
	  match "your-registration/confirmation" => 'registrations#updateNewConfirmation', :via => [:post,:put,:patch]
	  
	  match "your-registration/signup" => 'registrations#newSignup', :via => [:get], :as => :newSignup
	  match "your-registration/signup" => 'registrations#updateNewSignup', :via => [:post,:put,:patch]
	 
	  get "your-registration/confirm-account" => 'registrations#pending', :as => :pending 
	  match "your-registration/print" => 'registrations#print_confirmed', :via => [:get,:patch], :as => :print_confirmed
	   
	  get "your-registration/confirmed" => 'registrations#confirmed', :as => :confirmed 
    # Registration urls - Upper-tier process
    get "your-registration/registration-type" => "registrations#newRegistrationType", :via => [:get], :as => :newRegistrationType
    match "your-registration/registration-type" => "registrations#updateNewRegistrationType", :via => [:post,:put,:patch]

	  resources :registrations
    get "your-registration/upper/business-type" => "registrations#business_type", :as => :upper_business_type
    post "your-registration/upper/business-type" => "registrations#business_type_update"

    get "your-registration/upper/business-address" => "registrations#business_address", :as => :upper_business_address
    post "your-registration/upper/business-address" => "registrations#business_address_update"

    get "your-registration/upper/contact-detail" => "registrations#contact_detail", :as => :upper_contact_detail
    post "your-registration/upper/contact-detail" => "registrations#contact_detail_update"

    get "your-registration/upper/relevant-conviction" => "registrations#relevant_conviction", :as => :upper_relevant_conviction
    post "your-registration/upper/relevant-conviction" => "registrations#relevant_conviction_update"

    get "your-registration/upper/payment" => "registrations#payment", :as => :upper_payment
    post "your-registration/upper/payment" => "registrations#payment_update"

    get "your-registration/upper/summary" => "registrations#summary", :as => :upper_summary
    post "your-registration/upper/summary" => "registrations#summary_update"

	  #scope "/administration" do 
	  #  resources :agency_users
	  #end
	  
	  resources :discovers
#  end
  
  resources :agency_users

  get "agency_users/:id/confirm_delete" => 'agency_users#confirm_delete', :as => :confirm_delete_agency_user

  get "version" => 'home#version', :via => [:get], :as => :app_version

  # Add a route for a 404, Define this catch all unknowns last
  #if Rails.env.development?
  #	get "*path" => "registrations#notfound", via: [:get], :message => 'Page Not Found'
  #end

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
