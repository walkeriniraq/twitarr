class EventDecorator < BaseDecorator
  delegate_all
  include ActionView::Helpers::DateHelper
  def to_hash(options = {})
    result = {
        id: as_str(id),
        author: author,
        display_name: User.display_name_from_username(author),
        title: title,
        location: location,
        start_time: start_time,
        signups: signups
    }
    result[:end_time] = end_time unless end_time.blank?
    result[:description] = description unless description.blank?
    result[:max_signups] = max_signups unless max_signups.blank?
    result[:official] = official unless official.blank?
    result
  end
end