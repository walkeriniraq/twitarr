require 'singleton'

class DisplayNameCache
  include Singleton

  def initialize
    @cache = {}
  end

  def self.get_display_name(username)
    DisplayNameCache.instance.get_display_name username
  end

  def self.set_display_name(username, display_name)
    DisplayNameCache.instance.set_display_name username, display_name
  end

  def set_display_name(username, display_name)
    @cache[username] = display_name
  end

  def get_display_name(username)
    unless @cache.has_key? username
      DbConnectionPool.instance.connection do |redis|
        user = redis.user_store.get(username)
        if user.nil?
          @cache[username] = nil
        else
          @cache[username] = user.display_name
        end
      end
    end
    @cache[username]
  end

end