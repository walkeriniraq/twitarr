class EventDecorator < BaseDecorator
  delegate_all

  def to_meta_hash(username)
    result = {
        id: as_str(id),
        author: author,
        author_display_name: User.display_name_from_username(author),
        title: title,
        location: location,
        start_time: start_time
    }
    result[:end_time] = end_time unless end_time.blank?
    result[:following] = favorites.include? username
    result
  end

  def to_hash(username)
    result = {
        id: as_str(id),
        author: author,
        author_display_name: User.display_name_from_username(author),
        title: title,
        location: location,
        start_time: start_time
    }
    result[:end_time] = end_time unless end_time.blank?
    result[:description] = description unless description.blank?
    result[:following] = favorites.include? username
    result
  end
end
