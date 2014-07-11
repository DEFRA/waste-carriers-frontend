Ohm.redis = Redic.new(ENV['WCRS_FRONTEND_REDIS_DB'] || "redis://127.0.0.1:6379")
Rails.logger.debug "initialise Redis"
