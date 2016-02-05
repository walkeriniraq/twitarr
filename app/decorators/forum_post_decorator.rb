class ForumPostDecorator < BaseDecorator
  delegate_all

  def to_hash(username = nil, last_view = nil, options = {})
    ret = {
        id: id.to_s,
        forum_id: forum.id.to_s,
        author: author,
        display_name: User.display_name_from_username(author),
        author_last_photo_updated: User.last_photo_updated_from_username(author),
        text: replace_emoji(clean_text_with_cr(text), options),
        timestamp: timestamp,
        likes: some_likes(username),
        all_likes: all_likes(username),
        photos: decorate_photos,
        hash_tags: hash_tags,
#        location: location,
        mentions: mentions
    }
    ret[:new] = (timestamp > last_view) unless last_view.nil?
    ret
  end

  def decorate_photos
    return [] unless photos
    photos.map { |x| { id: x, animated: !x.blank? && PhotoMetadata.find(x).animated } }
  end

  def some_likes(username)
    favs = []
    unless username.nil?
      favs << 'You' if likes.include? username
    end
    if likes.count < 5
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

  def all_likes(username)
    favs = []
    unless username.nil?
      favs << 'You' if likes.include? username
    end
    favs += likes.reject { |x| x == username }
    return nil if favs.empty?
    favs
  end

end
