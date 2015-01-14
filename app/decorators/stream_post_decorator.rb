# noinspection RubyResolve
class StreamPostDecorator < BaseDecorator
  delegate_all
  include Twitter::Autolink

  MAX_LIST_LIKES = 5

  def to_hash(username = nil, options = {})
    result = {
        id: as_str(id),
        author: author,
        display_name: User.display_name_from_username(author),
        text: auto_link(clean_text_with_cr(text)),
        timestamp: timestamp,
        likes: some_likes(username),
        mentions: mentions,
        entities: entities,
        hash_tags: hash_tags,
        parent_chain: parent_chain
    }
    unless photo.blank?
      result[:photo] = { id: photo, animated: PhotoMetadata.find(photo).animated }
    end
    if options.has_key? :remove
      options[:remove].each { |k| result.delete k }
    end
    result
  end

  def to_base_hash
    result = {
        id: as_str(id),
        text: clean_text(text),
    }
    unless photo.blank?
      result[:photo_id] = photo
    end
    result
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
