Registrations::Application.routes.draw do
  devise_for :users, skip: [:registrations], controllers: { registrations: 'devise/registrations', confirmations: 'confirmations', passwords: 'passwords' }
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

  get "user/:id/registrations" => 'registrations#userRegistrations', :as => :userRegistrations

  # Static pages controller
  get '/account_confirmed' => 'pages#account_confirmed'
  get '/password_changed'  => 'pages#mid_registration_password_changed', as: :mid_registration_password_changed

  # Add routing for Public Search
  get "registrations/search" => 'registrations#publicSearch', :via => [:get], :as => :public

  get "registrations/finish" => 'registrations#finish', :as => :finish
  match "registrations/finish" => 'registrations#updateFinish', :via => [:post,:put,:patch]

  get "registrations/finish-assisted" => 'registrations#finishAssisted', :as => :finishAssisted
  match "registrations/finish-assisted" => 'registrations#updateFinishAssisted', :via => [:post,:put,:patch]

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
  get "registrations/(:reg_uuid)/start" => 'start#show', :as => :start
  post "registrations/:reg_uuid/start" => 'start#create', :as => :create_start

  scope path: 'your-registration/:reg_uuid' do

    scope controller: 'existing_registration' do
      get 'existing-registration', action: :show
      post 'existing-registration', action: :create
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
      post 'key-person', action: :update_ey_person

      get 'key-people/registration', action: :registration, as: :registration_key_people
      get 'key-people', action: :key_people
      post 'key-people', action: :update_key_people
      get 'key-people/delete', action: :delete_key_person
      get 'key-people/done', action: :done_key_people
    end

    scope controller: 'registrations' do
      get 'contact-details', action: :contact_details
      get 'contact-details/edit', action: :edit_contact_details
      post 'contact-details', action: :update_contact_details

      get 'confirmation', action: :confirmation
      post 'confirmation', action: :update_confirmation

      get 'relevant-convictions', action: :relevant_convictions
      post 'relevant-convictions', action: :update_relevant_convictions

    end

  end

  get "your-registration/relevant-people" => "key_people#newRelevantPeople", :as => :newRelevantPeople
  post "your-registration/relevant-people" => "key_people#updateNewRelevantPeople"
  get "your-registration/relevant-people/delete" => "key_people#deleteRelevantPerson", :as => :delete_relevant_person
  get "your-registration/relevant-people/done" => "key_people#doneRelevantPeople", :as => :done_relevant_people

  # Registrations - Confirmation

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

  get "your-registration/:id/order" => "order#new", :as => :upper_payment
  get "your-registration/:id/contact_us_to_complete_payment" => 'order#contact_us_to_complete_payment', :as => :contact_us_to_complete_payment
  get "your-registration/:id/order/editRegistration" => "registrations#newOrderEdit", :via => [:get], :as => :newOrderEdit
  get "your-registration/:id/order/renewRegistration" => "registrations#newOrderRenew", :via => [:get], :as => :newOrderRenew
  get "your-registration/:id/order/additionalCopyCards" => "registrations#newOrderCopyCards", :via => [:get], :as => :newOrderCopyCards
  match "your-registration/:id/order" => "order#create", :via => [:post,:put,:patch]
  get "your-registration/:id/CopyCardsComplete" => "registrations#copyCardComplete", :as => :complete_copy_cards
  get "your-registration/:id/EditRenewComplete" => "registrations#editRenewComplete", :as => :complete_edit_renew

  get 'your-registration/offline-payment' => 'registrations#newOfflinePayment', :as => :newOfflinePayment
  post 'your-registration/offline-payment' => 'registrations#updateNewOfflinePayment'

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

  if !Rails.env.production?
    # Template URLS - These are just for the devs as working examples
    get "templates/form" => "templates#formExample", :as => :formExample
    post "templates/form" => "templates#updateFormExample"
    get "templates/form-template" => "templates#formTemplate", :as => :formTemplate
    post "templates/form-template" => "templates#updateFormTemplate"
  end

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

  # Custom error handling routes
  match '/401', to: 'errors#client_error_401', via: :all
  match '/422', to: 'errors#client_error_422', via: :all
  match '/500', to: 'errors#server_error_500', via: :all
  match '/503', to: 'errors#server_error_503', via: :all

  # The 404 should be defined last as it will catch anything that rails does
  # not know how to route
  match '/404', to: 'errors#client_error_404', via: :all
end
