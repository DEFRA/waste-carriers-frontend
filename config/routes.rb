Registrations::Application.routes.draw do
  devise_for :users,
    skip: [:registrations],
    controllers: {
      registrations: 'devise/registrations',
      confirmations: 'confirmations',
      passwords: 'passwords'
    }
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

  # All routes managed by the Home controller
  root to: 'home#index'
  get 'home/index'
  get 'version' => 'home#version', :via => [:get], :as => :app_version
  get 'cookies' => 'home#cookies', :via => [:get], :as => :cookies
  get 'privacy' => 'home#privacy', :via => [:get], :as => :privacy
  get 'maintenance' => 'home#maintenance'

  get "user/:id/registrations" => 'registrations#userRegistrations', as: :user_registrations

  # Static pages controller
  get '/os_places_terms' => 'pages#os_places_terms'
  get '/account_confirmed' => 'pages#account_confirmed'
  get '/password_changed'  => 'pages#mid_registration_password_changed', as: :mid_registration_password_changed
  get '/renew(/:id)' => 'pages#renewal_extension'

  get "registrations/version" => 'registrations#version', :via => [:get], :as => :version
  get "registrations/:id/paymentstatus" => 'registrations#paymentstatus', :as => :paymentstatus

  get   "registrations/:id/payments" => 'payment#new', :via => [:get], :as => :enterPayment
  match "registrations/:id/payments" => 'payment#create', :via => [:post], :as => :savePayment
  get   "registrations/:id/writeOffs" => 'payment#newWriteOff', :via => [:get], :as => :enterWriteOff
  match "registrations/:id/writeOffs" => 'payment#createWriteOff', :via => [:post], :as => :saveWriteOff
  get   "registrations/:id/refunds" => 'payment#index', :via => [:get], :as => :refund
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
  get "registrations/:id/confirm_delete" => 'registrations#confirm_delete', :via => [:get], :as => :confirmDelete

  # Add a new route for the view certificate view
  match "registrations/:id/view" => 'registrations#view', :via => [:get,:patch], :as => :view

  # Add routing for revoke/unrevoke registration
  get "registrations/:id/revoke" => 'registrations#revoke', :via => [:get], :as => :revoke
  get "registrations/:id/unrevoke" => 'registrations#unRevoke', :via => [:get], :as => :unrevoke
  match "registrations/:id/revoke" => 'registrations#updateRevoke', :via => [:post]

  get "registrations/find" => 'start#show', :as => :find
  get "registrations/(:reg_uuid)/start" => 'start#show', :as => :start
  post "registrations/:reg_uuid/start" => 'start#create', :as => :create_start

  scope path: 'your-registration/:reg_uuid' do

    scope controller: 'existing_registration' do
      get 'existing-registration', action: :show
      post 'existing-registration', action: :create
    end

    scope controller: 'location' do
      get 'location', action: :show
      post 'location', action: :create
    end

    scope controller: 'register_in_northern_ireland' do
      get 'register-in-northern-ireland', action: :show
      post 'register-in-northern-ireland', action: :create
    end

    scope controller: 'register_in_scotland' do
      get 'register-in-scotland', action: :show
      post 'register-in-scotland', action: :create
    end

    scope controller: 'register_in_wales' do
      get 'register-in-wales', action: :show
      post 'register-in-wales', action: :create
    end

    scope controller: 'business_type' do
      get 'business-type', action: :show
      post 'business-type', action: :create
    end

    scope controller: 'no_registration' do
      get 'no-registration', action: :show
    end

    scope controller: 'other_businesses' do
      get 'other-businesses', action: :show
      post 'other-businesses', action: :create
    end

    scope controller: 'service_provided' do
      get 'service-provided', action: :show
      post 'service-provided', action: :create
    end

    scope controller: 'construction_demolition' do
      get 'construction-demolition', action: :show
      post 'construction-demolition', action: :create
    end

    scope controller: 'only_deal_with' do
      get 'only-deal-with', action: :show
      post 'only-deal-with', action: :create
    end

    scope controller: 'registration_type' do
      get 'registration-type', action: :show
      get 'registration-type/edit', action: :edit
      post 'registration-type', action: :create
    end

    scope controller: 'business_details' do
      get 'business-details', action: :show
      get 'business-details/edit', action: :edit
      post 'business-details', action: :create
    end

    scope controller: 'business_details_manual' do
      get 'business-details-manual', action: :show
      post 'business-details-manual', action: :create
    end

    scope controller: 'business_details_non_uk' do
      get 'business-details-non-uk', action: :show
      post 'business-details-non-uk', action: :create
    end

    scope controller: 'postal_address' do
      get 'postal-address', action: :show
      get 'postal-address/edit', action: :edit
      post 'postal-address', action: :create
    end

    scope controller: 'key_people' do
      get 'key-person', action: :key_person
      post 'key-person', action: :update_key_person

      get 'key-people/registration', action: :registration, as: :registration_key_people

      get 'key-people', action: :key_people
      post 'key-people', action: :update_key_people
      get 'key-people/:id/delete', action: :delete_key_person, as: :delete_key_person
      get 'key-people/done', action: :done_key_people, as: :done_key_people

      get 'relevant-people', action: :relevant_people, as: :relevant_people
      post 'relevant-people', action: :update_relevant_people, as: :update_relevant_people
      get 'relevant-people/:id/delete', action: :delete_relevant_person, as: :delete_relevant_person
      get 'relevant-people/done', action: :done_relevant_people, as: :done_relevant_people
    end

    scope controller: 'registrations' do
      get 'contact-details', action: :contact_details
      get 'contact-details/edit', action: :edit_contact_details
      match 'contact-details', action: :update_contact_details, via: [:post, :put, :patch]

      get 'declaration', action: :declaration
      match 'declaration', action: :update_declaration, via: [:post, :put, :patch]

      get 'relevant-convictions', action: :relevant_convictions
      match 'relevant-convictions', action: :update_relevant_convictions, via: [:post, :put, :patch]

      # User accounts
      get 'account-mode', action: :account_mode, as: :account_mode
      get 'signup', action: :signup
      match 'signup', action: :update_signup, via: [:post, :put, :patch]
      get 'signin', action: :signin
      match 'signin', action: :update_signin, via: [:post, :put, :patch]
      get 'confirm-account', action: :pending, as: :pending
      get 'confirmed', action: :confirmed, as: :confirmed
      match 'confirmed', action: :complete_confirmed, via: [:post, :put, :patch]

      get 'cannot-edit', action: :cannot_edit, as: :cannot_edit

      get 'order/edit-registration', action: :order_edit, as: :order_edit
      get 'order/renew-registration', action: :order_renew, as: :order_renew
      get 'order/order-copy_cards', action: :order_copy_cards, as: :order_copy_cards

      get 'copy-cards-complete', action: :copy_card_complete, as: :complete_copy_cards
      get 'edit-renew-complete', action: :edit_renew_complete, as: :complete_edit_renew

      get 'offline-payment', action: :offline_payment, as: :offline_payment
      post 'offline-payment', action: :update_offline_payment

      get 'finish', action: :finish, as: :finish
      match 'finish', action: :update_finish, as: :update_finish, via: [:post,:put,:patch]

      get 'finish-assisted', action: :finish_assisted, as: :finish_assisted
      match 'finish-assisted', action: :update_finish_assisted, as: :update_finish_assisted, via: [:post,:put,:patch]
    end

    scope controller: 'order' do
      get 'order', action: :new, as: :upper_payment
      match 'order', action: :create, via: [:post, :put, :patch]
      get 'contact_us_to_complete_payment', action: :contact_us_to_complete_payment, as: :contact_us_to_complete_payment
    end

    scope controller: 'worldpay' do
      get "worldpay/success/:order_code/:order_type", action: :success, as: :worldpay_success
      get "worldpay/failure/:order_code/:order_type", action: :failure, as: :worldpay_failure
      get "worldpay/pending/:order_code/:order_type", action: :pending, as: :worldpay_pending
      get "worldpay/cancel/:order_code/:order_type", action: :cancel, as: :worldpay_cancel
      get "worldpay/error/:order_code/:order_type", action: :error, as: :worldpay_error
    end

    unless Rails.env.production?
      # TODO Remove GET after having configured Worldpay order notifications in the WP Merchant Admin Interface
      get "worldpay/notification" => 'worldpay#order_notification'
      get "worldpay/refund" => 'worldpay#newRefund'
      post "worldpay/refund" => 'worldpay#updateNewRefund'

      #To be used by the Worldpay Order Notification service - the service will post to this URL
      post "worldpay/notification" => 'worldpay#update_order_notification', :as => :order_notification
    end


  end

  resources :registrations

  # routes for renewals and edits
  match "registrations/:uuid/edit" => 'registrations#edit', :via => [:get], :as => :edit
  match "registrations/:uuid/edit" => 'registrations#update', :via => [:post,:put,:patch]
  match "registrations/:uuid/edit_account_email" => 'registrations#edit_account_email', :via => [:get, :patch], :as => :edit_account_email

  # Data reporting urls - Authenticated agency users only
  get "reports/registrations" => 'reports#registrations_search', :as => :registrations_search
  match "reports/registrations" => 'reports#registrations_search_post', :via => [:post,:put,:patch]
  get "reports/registrations/results" => 'reports#registrations_search_results', :as => :registrations_search_results
  match "reports/registrations/results" => 'reports#registrations_export', :via => [:post,:put,:patch]

  get "reports/payments" => 'reports#payments_search', :as => :payments_search
  match "reports/payments" => 'reports#payments_search_post', :via => [:post,:put,:patch]
  get "reports/payments/results" => 'reports#payments_search_results', :as => :payments_search_results
  match "reports/payments/results" => 'reports#payments_export', :via => [:post,:put,:patch]

  get "reports/copy_cards" => 'reports#copy_cards_search', :as => :copy_cards_search
  match "reports/copy_cards" => 'reports#copy_cards_search_post', :via => [:post,:put,:patch]
  get "reports/copy_cards/results" => 'reports#copy_cards_search_results', :as => :copy_cards_search_results
  match "reports/copy_cards/results" => 'reports#copy_cards_export', :via => [:post,:put,:patch]

  resources :agency_users

  get "agency_users/:id/confirm_delete" => 'agency_users#confirm_delete', :as => :confirm_delete_agency_user

  # Custom error handling routes
  match '/401', to: 'errors#client_error_401', via: :all
  match '/422', to: 'errors#client_error_422', via: :all
  match '/500', to: 'errors#server_error_500', via: :all
  match '/503', to: 'errors#server_error_503', via: :all

  # The 404 should be defined last as it will catch anything that rails does
  # not know how to route
  match '/404', to: 'errors#client_error_404', via: :all
end
