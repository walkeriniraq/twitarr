class ForumPostDecorator < Draper::Decorator
  delegate_all

  def to_hash
    {
        id: id.to_s,
        author: author,
        text: text,
        timestamp: timestamp,
        likes: likes,
        likes_counts: likes.length,
        photos: decorate_photos
    }
  end

  def decorate_photos
    return [] unless photos
    photos.map { |x| { id: x, animated: !x.blank? && PhotoMetadata.find(x).animated } }
  end

end