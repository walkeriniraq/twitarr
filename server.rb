require 'sass'
require 'redis'
require 'json'
require_relative 'app/db_connection_pool'

class Server < Kul::BaseServer

  DbConnectionPool.instance.configure(host: 'gremlin')

end