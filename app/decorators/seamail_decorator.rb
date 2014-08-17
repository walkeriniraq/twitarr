class SeamailDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::TextHelper

  def to_meta_hash
    {
        id: id.to_s,
        users: users.map { |x| x.username },
        subject: subject,
        messages: pluralize(seamail_messages.count, 'message'),
        timestamp: last_message
    }
  end

  def to_hash
    {
        id: id.to_s,
        users: users.map { |x| x.username },
        subject: subject,
        messages: seamail_messages.map { |x| x.decorate.to_hash }
    }
  end

end