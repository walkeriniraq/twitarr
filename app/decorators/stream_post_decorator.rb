class StreamPostDecorator < Draper::Decorator
  delegate_all

  def to_hash(username = nil)
    puts "IN TO_HASH WITH USERNAME: #{username.to_s}"
    {
        id: id,
        author: author,
        text: text,
        timestamp: timestamp,
        photo: photo,
        favorites: some_favorites(username)
    }
  end

  def some_favorites(username)
    favs = []
    unless username.nil?
      favs << 'You' if favorites.include? username
    end
    if favorites.count < 20
      favs += favorites.reject { |x| x == username }
    else
      favs << "#{favorites.count} seamonkeys"
    end
    return nil if favs.empty?
    favs
  end

end
