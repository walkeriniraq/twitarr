require_relative 'redis_storage_strategy'

module BaseModelInstanceMethods

  def self.included(klass)
    klass.extend BaseModelClassMethods
  end

  def to_hash(*keys)
    keys.reduce({}) do |hash, key|
      hash[key] = send(key)
      hash
    end
  end

  def update(values)
    values.each do |k, v|
      if respond_to? k.to_s
        # this lets us initialize classes with attr_reader
        instance_variable_set "@#{k.to_s}", v
      else
        #TODO: replace this with some sort of logging
        puts "Invalid parameter passed to class #{self.class.to_s} initialize: #{k.to_s} - value: #{v.to_s}"
      end
    end
  end

  #def indexing
  #  self.class.indexing
  #end
  #
  #def storage
  #  self.class.storage
  #end
  #
  #def twitarr=(twitarr)
  #  @twitarr = twitarr
  #end
  #
  #def twitarr
  #  @twitarr ||= Twitarr.new
  #end

  #def db_pipeline(db = nil, &block)
  #  self.class.db_pipeline(db, &block)
  #end

  module BaseModelClassMethods
    #def storage=(storage)
    #  @storage = storage
    #end
    #
    #def indexing=(indexing)
    #  @indexing = indexing
    #end
    #
    #def storage
    #  @storage ||= RedisStorageStrategy.new(self)
    #end
    #
    #def indexing
    #  @indexing ||= RedisIndexingStrategy.new(self)
    #end


    #def db_pipeline(db = nil)
    #  ret = nil
    #  if db.nil?
    #    DbConnectionPool.instance.connection do |db|
    #      db.pipelined { |pipeline| ret = yield pipeline }
    #    end
    #  elsif db.client.is_a? RubyRedis::Pipeline
    #    ret = yield db
    #  else
    #    db.pipelined { |pipeline| ret = yield pipeline }
    #  end
    #  ret
    #end
    #
    #def db_call
    #  DbConnectionPool.instance.connection do |db|
    #    yield db
    #  end
    #end

  end

end

class BaseModel
  include BaseModelInstanceMethods
  include HashInitialize
end
