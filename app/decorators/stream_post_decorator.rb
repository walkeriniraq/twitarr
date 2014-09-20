class StreamPostDecorator < Draper::Decorator
  delegate_all

  def to_hash
    {
        id: id,
        author: author,
        text: text,
        timestamp: timestamp,
        photo: photo
    }
  end

end
