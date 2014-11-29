# noinspection RubyResolve
class StreamPostDecorator < Draper::Decorator
  delegate_all
  include Twitter::Autolink

  MAX_LIST_LIKES = 5

  def to_hash(username = nil)
    {
        id: as_str(id),
        author: author,
        #  TODO: figure this thing out
        # text: text,
        text: auto_link(text, username_url_base: '#/user/', hashtag_url_base: '#/tag/', cashtag_url_base: '#/tag/', suppress_lists: true, suppress_no_follow: true),
        timestamp: timestamp.to_i,
        photo: photo,
        likes: some_likes(username),
        mentions: mentions,
        entities: entities,
        hash_tags: hash_tags,
    }
  end

  def some_likes(username)
    favs = []
    unless username.nil?
      favs << 'You' if likes.include? username
    end
    if likes.count < MAX_LIST_LIKES
      favs += likes.reject { |x| x == username }
    else
      if likes.include? username
        favs << "#{likes.count - 1} other seamonkeys"
      else
        favs << "#{likes.count} seamonkeys"
      end
    end
    return nil if favs.empty?
    favs
  end

end
