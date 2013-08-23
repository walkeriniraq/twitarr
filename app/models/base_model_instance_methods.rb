module BaseModelInstanceMethods

  def self.included(klass)
    klass.extend BaseModelClassMethods
  end

  def db_pipeline(db = nil, &block)
    self.class.db_pipeline(db, &block)
  end

  module BaseModelClassMethods

    def db_pipeline(db = nil)
      ret = nil
      if db.nil?
        DbConnectionPool.instance.connection do |db|
          db.pipelined { ret = yield db }
        end
      elsif db.client.is_a? RubyRedis::Pipeline
        ret = yield db
      else
        db.pipelined { ret = yield db }
      end
      ret
    end

    def db_call
      DbConnectionPool.instance.connection do |db|
        yield db
      end
    end

  end

end