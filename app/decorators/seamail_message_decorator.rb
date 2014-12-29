class SeamailMessageDecorator < Draper::Decorator
  delegate_all

  def to_hash
    {
        author: author,
        author_display_name: User.display_name_from_username(author),
        text: text,
        timestamp: timestamp
    }
  end

end