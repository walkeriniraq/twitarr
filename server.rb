require 'sass'
require 'redis'
require 'json'
require_relative 'app/database'

class Server < Kul::BaseServer

  def redis_connection
    # TODO: cache this
    #Redis.new(:host => 'gremlin')
    Redis.new
  end

  def database
    Database.new(redis_connection)
  end

end