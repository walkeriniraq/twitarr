require 'redis'
require 'singleton'

class DbConnectionPool
  include Singleton

  def initialize
    @connection_hash = {}
  end

  def connection
    yield Redis.new(@connection_hash)
  end

  def configure(connection_hash)
    @connection_hash = connection_hash
  end

end