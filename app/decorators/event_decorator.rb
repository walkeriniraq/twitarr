class EventDecorator < BaseDecorator
  delegate_all

  def to_meta_hash(username)
    result = {
        id: as_str(id),
        title: title,
        location: location,
        start_time: start_time,
        official: official
    }
    result[:end_time] = end_time unless end_time.blank?
    result[:following] = favorites.include? username
    result
  end

  def to_hash(username)
    result = to_hash username
    result[:description] = description unless description.blank?
    result
  end
end
