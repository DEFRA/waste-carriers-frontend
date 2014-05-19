class ActivateExistingUsers < ActiveRecord::Migration

  ## Activate existing user accounts, which were created before the registration verification feature
  ## (i.e. activation/confirmation of user account e-mail addresses) was introduced. 
  def change
    Rails.logger.info("BEGIN - Updating existing users...")
    User.all.each { |u|
      if !u.confirmed?
        puts "Confirming " + u.email
        #u.confirm!
        u.skip_confirmation!
        if !u.save
          puts "ERROR - user could not be saved due to validation error. email = " + u.email
          puts "Errors: " + u.errors.full_messages.to_s
          u.save(:validate => false)
          puts "Saved anyway without validation. email = " + u.email
        end
      else
        puts "Already confirmed - " + u.email
      end
    }
    Rails.logger.info("END - Users updated")
  end

end
