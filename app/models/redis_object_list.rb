class RedisObjectList
  attr_reader :list, :clazz

  def initialize(list, clazz)
    @list = list
    @clazz = clazz
  end

  def unshift(obj)
    list << obj.to_hash(obj.class.fattrs).to_json
  end

  def [](from, count = 1)
    list[from, count].map { |x| clazz.new(JSON.parse x) }
  end

end