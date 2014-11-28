# noinspection RubyResolve
class StreamPostDecorator < Draper::Decorator
  delegate_all

  MAX_LIST_LIKES = 10

  def to_hash(username = nil)
    {
        id: as_str(id),
        author: author,
        text: text,
        timestamp: timestamp.to_i,
        photo: photo,
        likes: some_likes(username),
        mentions: mentions,
        entities: entities,
        hash_tags: hash_tags,
        photo: photo
    }
  end

  def some_likes(username)
    favs = []
    unless username.nil?
      favs << 'You' if likes.include? username
    end
    if favorites.count < 20
      favs += likes.reject { |x| x == username }
    else
      favs << "#{likes.count} seamonkeys"
    end
    return nil if favs.empty?
    favs
  end

  def as_str(v)
    return v.to_str if v.is_a? BSON::ObjectId
    v
  end

end
