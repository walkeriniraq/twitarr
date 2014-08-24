class SeamailMessageDecorator < Draper::Decorator
  delegate_all

  def to_hash
    {
        author: author,
        text: text,
        timestamp: timestamp
    }
  end

end