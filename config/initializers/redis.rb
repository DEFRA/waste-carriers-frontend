Ohm.redis = Redic.new(ENV['WCRS_REDIS_DB_URL'] || "redis://127.0.0.1:6379")
Rails.logger.debug "initialise Redis"
