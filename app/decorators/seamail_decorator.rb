class SeamailDecorator < Draper::Decorator
  delegate_all

  def to_meta_hash
    {
        id: id.to_s,
        users: users,
        messages: seamail_messages.count,
        timestamp: last_message
    }
  end

  def to_hash
    {
        id: id.to_s,
        users: users,
        messages: seamail_messages.map { |x| x.decorate.to_hash }
    }
  end

end