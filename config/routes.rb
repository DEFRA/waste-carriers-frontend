Registrations::Application.routes.draw do

  devise_for :users, :skip => [:registrations], :controllers => { :registrations => "devise/registrations"}
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
    as :agency_user do
      get 'admins/edit' => 'devise/registrations#edit', :as => 'edit_admin_registration'    
      put 'admins/:id' => 'devise/registrations#update', :as => 'admin_registration'            
    end

  root :to => "home#index"

  get "home/index"
  get "registrations/start" => 'registrations#start', :as => :start
  get "registrations/:id/finish" => 'registrations#finish', :as => :finish
  match "registrations/:id/ncccedit" => 'registrations#ncccedit', :via => [:get], :as => :ncccedit
  match "registrations/:id/ncccedit" => 'registrations#ncccupdate', :via => [:post,:put,:patch]
  
  # Add a new route for the print view
  match "registrations/:id/print" => 'registrations#print', :via => [:get,:patch], :as => :print

  resources :registrations

  resources :agency_users

  # Add a route for a 404, Define this catch all unknowns last
  if Rails.env.development?
  	get "*path" => "registrations#notfound", via: [:get], :message => 'Page Not Found'
  end

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
