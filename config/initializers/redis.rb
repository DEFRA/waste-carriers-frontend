Ohm.redis = Redic.new(ENV['WCRS_REDIS_DB'] || "redis://127.0.0.1:6379")
Rails.logger.debug "initiase Redis"
