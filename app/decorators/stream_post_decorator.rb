class StreamPostDecorator < Draper::Decorator
  delegate_all

  MAX_LIST_LIKES = 10

  def to_hash
    {
        id: as_str(id),
        author: author,
        text: text,
        timestamp: timestamp,
        likes: likes,
        likes_counts: likes.length,
        epoch: (timestamp.to_f * 1000).to_i,
        photo: photo
    }
  end

  def likes_info
    if likes.length > MAX_LIST_LIKES
      {likes: likes[0..MAX_LIST_LIKES-1], likes_counts: likes.length}
    else
      {likes: likes, likes_counts: likes.length}
    end
  end

  def to_list_hash
    h = to_hash.merge!(likes_info)
    puts h
    h
  end

  def as_str(v)
    return v.to_str if v.is_a? BSON::ObjectId
    v
  end

end
