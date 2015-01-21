class ForumPostDecorator < BaseDecorator
  delegate_all

  def to_hash(last_view = nil)
    ret = {
        id: id.to_s,
        author: author,
        display_name: User.display_name_from_username(author),
        text: clean_text_with_cr(text),
        timestamp: timestamp,
        likes: likes,
        likes_counts: likes.length,
        photos: decorate_photos,
        hash_tags: hash_tags,
        mentions: mentions
    }
    ret[:new] = (timestamp > last_view) unless last_view.nil?
    ret
  end

  def decorate_photos
    return [] unless photos
    photos.map { |x| { id: x, animated: !x.blank? && PhotoMetadata.find(x).animated } }
  end

end