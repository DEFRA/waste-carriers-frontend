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

    # Add routing for Public Search
    get "registrations/search" => 'registrations#publicSearch', :via => [:get], :as => :public

    get "registrations/finish" => 'registrations#finish', :as => :finish
    match "registrations/finish" => 'registrations#updateFinish', :via => [:post,:put,:patch]

    get "registrations/finish-assisted" => 'registrations#finishAssisted', :as => :finishAssisted
    match "registrations/finish-assisted" => 'registrations#updateFinishAssisted', :via => [:post,:put,:patch]

    get "registrations/version" => 'registrations#version', :via => [:get], :as => :version
    get "registrations/data-protection" => 'registrations#dataProtection', :via => [:get], :as => :dataProtection
    get "registrations/:id/paymentstatus" => 'registrations#paymentstatus', :as => :paymentstatus

    get   "registrations/:id/payments" => 'payment#new', :via => [:get], :as => :enterPayment
    match "registrations/:id/payments" => 'payment#create', :via => [:post], :as => :savePayment
    get   "registrations/:id/writeOffs" => 'payment#newWriteOff', :via => [:get], :as => :enterWriteOff
    match "registrations/:id/writeOffs" => 'payment#createWriteOff', :via => [:post], :as => :saveWriteOff
    get   "registrations/:id/refunds" => 'payment#index', :via => [:get], :as => :refund
    #   match "registrations/:id/refunds" => 'payment#createRefund', :via => [:post], :as => :saveRefund
    get   "registrations/:id/manualRefund/:orderCode" => 'payment#manualRefund', :via => [:get], :as => :manualRefund
    match "registrations/:id/manualRefund/:orderCode" => 'payment#createManualRefund', :via => [:post]
    get   "registrations/:id/worldpayRefund/:orderCode" => 'payment#newWPRefund', :via => [:get]
    match "registrations/:id/worldpayRefund/:orderCode" => 'payment#createWPRefund', :via => [:post]
    get   "registrations/:id/refund/:orderCode/refundComplete" => 'payment#completeRefund', :via => [:get]
    get   "registrations/:id/worldpayRefund/:orderCode/retry" => 'payment#retryWPRefundRequest', :via => [:get], :as => :retryRefund
    get   "registrations/:id/chargeAdjustments" => 'payment#chargeIndex', :via => [:get], :as => :chargeAdjustment
    match "registrations/:id/chargeAdjustments" => 'payment#selectAdjustment', :via => [:post]
    get   "registrations/:id/paymentReversals" => 'payment#reversalIndex', :via => [:get], :as => :paymentReversal
    get   "registrations/:id/newReversal/:orderCode" => 'payment#newReversal', :via => [:get], :as => :newReversal
    match "registrations/:id/newReversal/:orderCode" => 'payment#createReversal', :via => [:post]
    get   "registrations/:id/newAdjustment" => 'payment#newAdjustment', :via => [:get], :as => :newAdjustment
    match "registrations/:id/newAdjustment" => 'payment#createAdjustment', :via => [:post]

    # Add routing for confirm delete registration
    get "registrations/:id/confirmDelete" => 'registrations#confirmDelete', :via => [:get], :as => :confirmDelete

    # Add a new route for the view certificate view
    match "registrations/:id/view" => 'registrations#view', :via => [:get,:patch], :as => :view

    # Add routing for revoke/unrevoke registration
    get "registrations/:id/revoke" => 'registrations#revoke', :via => [:get], :as => :revoke
    get "registrations/:id/unrevoke" => 'registrations#unRevoke', :via => [:get], :as => :unrevoke
    match "registrations/:id/revoke" => 'registrations#updateRevoke', :via => [:post]
    # Add routing for approve/refuse registration
    get "registrations/:id/approve"   => 'registrations#approve', :via => [:get], :as => :approve
    get "registrations/:id/refuse"    => 'registrations#refuse',  :via => [:get], :as => :refuse
    match "registrations/:id/approve" => 'registrations#updateApprove', :via => [:post]

    get "registrations/find" => 'start#show', :as => :find
    get "registrations/start" => 'start#show', :as => :start
    post "registrations/start" => 'start#create'

    get "your-registration/existing-registration" => 'existing_registration#show', :as => :existing_registration
    post "your-registration/existing-registration" => 'existing_registration#create'

    # Registration urls - Smart answers
    get "your-registration/business-type" => 'business_type#show', :as => :business_type
    post "your-registration/business-type" => 'business_type#create'

    get "your-registration/no-registration" => 'no_registration#show', :as => :no_registration

    get "your-registration/other-businesses" => 'other_businesses#show', :as => :other_businesses
    post "your-registration/other-businesses" => 'other_businesses#create'

    get "your-registration/service-provided" => 'service_provided#show', :as => :service_provided
    post "your-registration/service-provided" => 'service_provided#create'

    get "your-registration/construction-demolition" => 'construction_demolition#show', :as => :construction_demolition
    post "your-registration/construction-demolition" => 'construction_demolition#create'

    get "your-registration/only-deal-with" => 'only_deal_with#show', :as => :only_deal_with
    post "your-registration/only-deal-with" => 'only_deal_with#create'

    get "your-registration/registration-type" => "registration_type#show", :as => :registration_type
    get "your-registration/registration-type/edit" => "registration_type#edit", :as => :edit_registration_type
    post "your-registration/registration-type" => "registration_type#create"

    # Registration urls - Lower tier
    match "your-registration/business-details" => 'registrations#newBusinessDetails', :via => [:get], :as => :newBusinessDetails
    get   "your-registration/edit/business-details" => "registrations#editBusinessDetails", :via => [:get], :as => :editBusinessDetails
    match "your-registration/business-details" => 'registrations#updateNewBusinessDetails', :via => [:post,:put,:patch]

    match "your-registration/contact-details" => 'registrations#newContactDetails', :via => [:get], :as => :newContact
    get   "your-registration/edit/contact-details" => "registrations#editContactDetails", :via => [:get], :as => :editContact
    match "your-registration/contact-details" => 'registrations#updateNewContactDetails', :via => [:post,:put,:patch]

    match "your-registration/confirmation" => 'registrations#newConfirmation', :via => [:get], :as => :newConfirmation
    match "your-registration/confirmation" => 'registrations#updateNewConfirmation', :via => [:post,:put,:patch]

    get "your-registration/account-mode" => 'registrations#account_mode', :as => :account_mode

    match "your-registration/signup" => 'registrations#newSignup', :via => [:get], :as => :newSignup
    match "your-registration/signup" => 'registrations#updateNewSignup', :via => [:post,:put,:patch]

    get "your-registration/signin" => 'registrations#newSignin', :as => :newSignin
    match "your-registration/signin" => 'registrations#updateNewSignin', :via => [:post,:put,:patch]

    get "your-registration/confirm-account" => 'registrations#pending', :as => :pending

    get "your-registration/confirmed" => 'registrations#confirmed', :as => :confirmed
    match "your-registration/confirmed" => 'registrations#completeConfirmed', :via => [:post]

    get "your-registration/cannot-edit" => 'registrations#cannot_edit', :as => :cannot_edit

    resources :registrations

    get "your-registration/key-people/registration" => "key_people#registration", :as => :registration_key_people
    get "your-registration/key-person" => "key_people#newKeyPerson", :as => :newKeyPerson
    post "your-registration/key-person" => "key_people#updateNewKeyPerson"
    match "your-registration/key_people" => 'key_people#newKeyPeople', :via => [:get], :as => :newKeyPeople
    match "your-registration/key_people" => 'key_people#updateNewKeyPeople', :via => [:post,:put,:patch]
    get "your-registration/key-people/delete" => "key_people#delete", :as => :delete_key_person
    get "your-registration/key-people/done" => "key_people#doneKeyPeople", :as => :done_key_people

    get "your-registration/relevant-convictions" => "registrations#newRelevantConvictions", :via => [:get], :as => :newRelevantConvictions
    match "your-registration/relevant-convictions" => "registrations#updateNewRelevantConvictions", :via => [:post,:put,:patch]

    get "your-registration/relevant-people" => "key_people#newRelevantPeople", :as => :newRelevantPeople
    post "your-registration/relevant-people" => "key_people#updateNewRelevantPeople"
    get "your-registration/relevant-people/delete" => "key_people#deleteRelevantPerson", :as => :delete_relevant_person
    get "your-registration/relevant-people/done" => "key_people#doneRelevantPeople", :as => :done_relevant_people

    get "your-registration/:id/order" => "order#new", :as => :upper_payment
    get "your-registration/:id/order/editRegistration" => "registrations#newOrderEdit", :via => [:get], :as => :newOrderEdit
    get "your-registration/:id/order/renewRegistration" => "registrations#newOrderRenew", :via => [:get], :as => :newOrderRenew
    get "your-registration/:id/order/additionalCopyCards" => "registrations#newOrderCopyCards", :via => [:get], :as => :newOrderCopyCards
    match "your-registration/:id/order" => "order#create", :via => [:post,:put,:patch]
    get "your-registration/:id/CopyCardsComplete" => "registrations#copyCardComplete", :as => :complete_copy_cards
    get "your-registration/:id/EditRenewComplete" => "registrations#editRenewComplete", :as => :complete_edit_renew

    # routes for renewals and edits
    match "registrations/:uuid/edit" => 'registrations#edit', :via => [:get], :as => :edit
    match "registrations/:uuid/edit" => 'registrations#update', :via => [:post,:put,:patch]

    # Data reporting urls - Authenticated agency users only
    get "reports/registrations" => 'reports#registrations_search', :as => :registrations_search
    match "reports/registrations" => 'reports#registrations_search_post', :via => [:post,:put,:patch]
    get "reports/registrations/results" => 'reports#registrations_search_results', :as => :registrations_search_results
    match "reports/registrations/results" => 'reports#registrations_export', :via => [:post,:put,:patch]

    get "reports/payments" => 'reports#payments_search', :as => :payments_search
    match "reports/payments" => 'reports#payments_search_post', :via => [:post,:put,:patch]
    get "reports/payments/results" => 'reports#payments_search_results', :as => :payments_search_results
    match "reports/payments/results" => 'reports#payments_export', :via => [:post,:put,:patch]

    if !Rails.env.production?
      # Template URLS - These are just for the devs as working examples
      get "templates/form" => "templates#formExample", :as => :formExample
      post "templates/form" => "templates#updateFormExample"
      get "templates/form-template" => "templates#formTemplate", :as => :formTemplate
      post "templates/form-template" => "templates#updateFormTemplate"
    end

    get 'your-registration/offline-payment' => 'registrations#newOfflinePayment', :as => :newOfflinePayment
    post 'your-registration/offline-payment' => 'registrations#updateNewOfflinePayment'


    # Worldpay response messages
    get "worldpay/success"
    get "worldpay/failure"
    get "worldpay/pending"
    get "worldpay/cancel"
    get "worldpay/error"

    if !Rails.env.production?
    #TODO Remove GET after having configured Worldpay order notifications in the WP Merchant Admin Interface
      get "worldpay/notification" => 'worldpay#order_notification'
      get "worldpay/refund" => 'worldpay#newRefund'
      post "worldpay/refund" => 'worldpay#updateNewRefund'

      #To be used by the Worldpay Order Notification service - the service will post to this URL
      post "worldpay/notification" => 'worldpay#update_order_notification', :as => :order_notification
    end


    resources :agency_users

    get "agency_users/:id/confirm_delete" => 'agency_users#confirm_delete', :as => :confirm_delete_agency_user

    get "version" => 'home#version', :via => [:get], :as => :app_version

    get "cookies" => 'home#cookies', :via => [:get], :as => :cookies

    get "privacy" => 'home#privacy', :via => [:get], :as => :privacy

  #end


  # Add a route for a 404, Define this catch all unknowns last
  #if Rails.env.development?
  #  get "*path" => "registrations#notfound", via: [:get], :message => 'Page Not Found'
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
