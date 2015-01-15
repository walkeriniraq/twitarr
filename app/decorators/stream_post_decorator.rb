# noinspection RubyResolve
class StreamPostDecorator < BaseDecorator
  delegate_all
  include Twitter::Autolink

  MAX_LIST_LIKES = 5

  def to_hash(username = nil, options = {})
    length_limit = options[:length_limit] || text.length
    adjusted_text = (text)[0...length_limit]

    result = {
        id: as_str(id),
        author: author,
        display_name: User.display_name_from_username(author),
        text: auto_link(clean_text_with_cr(adjusted_text)),
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
    if options.has_key? :length_limit
      result[:text] << "<br><a href=\"/#/stream/tweet/#{as_str(id)}\">Read More</a>" if text.length > options[:length_limit]
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
