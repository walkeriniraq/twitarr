class ForumDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::TextHelper

  def to_meta_hash
    {
        id: id.to_s,
        subject: subject,
        created_by: created_by,
        posts: pluralize(post_count, 'post'),
        timestamp: last_post
    }
  end

  def to_hash
    {
        id: id.to_s,
        subject: subject,
        created_by: created_by,
        posts: posts.map { |x| x.decorate.to_hash }
    }
  end

end