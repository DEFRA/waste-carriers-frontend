require 'SecureRandom'

namespace :account_creation do
  # Creates a new Assisted Digital Account Manager user.
  # This maps to an Admin, with the 'Refunds' role assigned.
  task :create_ad_account_manager, [:email] => :environment do |t, args|
    # Check that an email address has been supplied.
    args.with_defaults(:email => '')
    if (args.email.empty?)
      fail 'ERROR: Account email address must be specified.'
    end
    
    # Check Admin with specified email address does not already exist.
    if Admin.find_by_email(args.email) != nil
      fail 'ERROR: An account with this email address alread exists.'
    end
    
    # Create the new account, using a randomised password.
    puts 'Creating a new Assisted Digital Account Manager...'
    puts "Using email address '#{args.email}' and randomised password..."
    admin = Admin.new(:email => args.email, :password => SecureRandom.base64(10))
    admin.add_role :Role_agencyRefundPayment, Admin
    admin.save!
    puts 'Advise the user to set their initial password using the password recovery link.'
  end
  
  # Creates a new Finance Account Manager user.
  # This maps to an Admin, with the 'Finance Superuser' role assigned.
  task :create_finance_account_manager, [:email] => :environment do |t, args|
    # Check that an email address has been supplied.
    args.with_defaults(:email => '')
    if (args.email.empty?)
      fail 'ERROR: Account email address must be specified.'
    end
    
    # Check Admin with specified email address does not already exist.
    if Admin.find_by_email(args.email) != nil
      fail 'ERROR: An account with this email address alread exists.'
    end
    
    # Create the new account, using a randomised password.
    puts 'Creating a new Finance Account Manager...'
    puts "Using email address '#{args.email}' and randomised password..."
    admin = Admin.new(:email => args.email, :password => SecureRandom.base64(10))
    admin.add_role :Role_financeSuper, Admin
    admin.save!
    puts 'Advise the user to set their initial password using the password recovery link.'
  end

end
