class RedisObjectSet
  attr_reader :set, :clazz

  def initialize(set, clazz)
    @set = set
    @clazz = clazz
  end

  def save(obj, score)
    set[obj.to_hash(obj.class.fattrs).to_json] = score
  end

  def get(from_score, to_score, limit = 0)
    options = {}
    options[:limit] = limit if limit > 0
    list = if from_score < to_score
             set.rangebyscore(from_score, to_score, options)
           else
             set.revrangebyscore(from_score, to_score, options)
           end
    list.map { |x| clazz.new(JSON.parse x) }
  end

end