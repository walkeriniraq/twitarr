class StreamPostDecorator < Draper::Decorator
  delegate_all

  def to_hash
    {
        id: as_str(id),
        author: author,
        text: text,
        timestamp: timestamp,
        epoch: (timestamp.to_f * 1000).to_i,
        photo: photo
    }
  end

  def as_str(v)
    return v.to_str if v.is_a? BSON::ObjectId
    v
  end

end
