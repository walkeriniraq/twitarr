module Mongoid::Document
  def as_str(v)
    return v.to_str if v.is_a? BSON::ObjectId
    v
  end
end
class Mongoid::Criteria
  def has_more?
    return false unless options.limit
    count > options.limit + (options.skip || 0)
  end
end