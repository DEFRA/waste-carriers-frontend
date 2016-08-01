# Monkey-patch to ensure we don't capture personal data for signed-in users via
# Devise / Warden.
module Airbrake
  module Rack
    class User
      # Finds the user in the Rack environment and creates a new user wrapper.
      #
      # @param [Hash{String=>Object}] rack_env The Rack environment
      # @return [Airbrake::Rack::User, nil]
      def self.extract(rack_env)
        # Attempt to get current customer, agency user, or admin.
        if (warden = rack_env['warden'])
          user_types = [:user, :agency_user, :admin]
          user_types.each do |user_type|
            if (user = warden.authenticate(scope: user_type, run_callbacks: false))
              return new(user) if user
            end
          end
        end

        # Fallback, if the above didn't work.
        super(rack_env)
      end

      # Custom method that doesn't log email address, but does include user class.
      def as_json
        user = {}
        user[:id] = try_to_get(:id)
        user[:type] = try_to_get(:class)
        user = user.delete_if { |_key, val| val.nil? }
        user.empty? ? user : { user: user }
      end
    end
  end
end
