require 'redis'
require 'singleton'

# r.zadd 'tag:@kvort', Time.now.to_i, '12348'
# r.zrange('tag:@kvort', -10, -1, { :with_scores => true }).map { |k, v| [k, Time.at(v)] }

class DbConnectionPool
  include Singleton

  def initialize
    @connection_hash = {}
  end

  def configure(connection_hash)
    @connection_hash = connection_hash
  end

  def connection
    yield Redis.new(@connection_hash)
  end

end