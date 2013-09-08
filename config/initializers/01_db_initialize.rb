require Rails.root + 'lib/db_connection_pool'

DbConnectionPool.instance.configure(Rails.application.config.db)

# this is a horrible hack due to the way that redis objects are configured
Redis::Objects.redis = Redis.new Rails.application.config.db
