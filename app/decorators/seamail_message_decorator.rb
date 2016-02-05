class SeamailMessageDecorator < BaseDecorator
  delegate_all

  def to_hash(options = {})
    {
        author: author,
        author_display_name: User.display_name_from_username(author),
        author_last_photo_updated: User.last_photo_updated_from_username(author),
        text: replace_emoji(clean_text_with_cr(text), options),
        timestamp: timestamp
    }
  end

end
