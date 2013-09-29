require 'redis'
require 'singleton'

class DbConnectionPool
  include Singleton

  def initialize
    @connection_hash = {}
  end

  def connection
    @pool ||= ConnectionPool.new(:size => 20, :timeout => 5) { Redis.new(@connection_hash) }
    @pool.with do |conn|
      yield conn
    end
  end

  def slow_connection
    @slow_pool ||= ConnectionPool::Wrapper.new(:size => 1, :timeout => 5) { Redis.new(@connection_hash) }
  end

  def configure(connection_hash)
    @connection_hash = connection_hash
  end

end