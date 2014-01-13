class ActivateExistingUsers < ActiveRecord::Migration

  ## Activate existing user accounts, which were created before the registration verification feature
  ## (i.e. activation/confirmation of user account e-mail addresses) was introduced. 
  def change
    Rails.logger.info("BEGIN - Updating existing users...")
    Rails.logger.info("END - Users updated")
  end

end
