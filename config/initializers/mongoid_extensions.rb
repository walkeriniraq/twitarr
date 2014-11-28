module Mongoid::Document
  def as_str(v)
    return v.to_str if v.is_a? BSON::ObjectId
    v
  end
end