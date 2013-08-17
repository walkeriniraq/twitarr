require 'redis'
require 'singleton'

class DbConnectionPool
  include Singleton

  def initialize
    @connection_hash = {}
  end

  def connection
    @pool = ConnectionPool.new(:size => 20, :timeout => 5, always_new_connection: true) { Redis.new(@connection_hash) } if @pool.nil?
    @pool.with do |conn|
      yield conn
    end
  end

  def configure(connection_hash)
    @connection_hash = connection_hash
  end

end