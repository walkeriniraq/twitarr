class ForumDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::TextHelper

  def to_meta_hash
    {
        id: id.to_s,
        subject: subject,
        last_post_username: posts.last.author,
        last_post_display_name: User.display_name_from_username(posts.last.author),
        posts: pluralize(post_count, 'post'),
        timestamp: last_post
    }
  end

  def to_hash
    {
        id: id.to_s,
        subject: subject,
        posts: posts.map { |x| x.decorate.to_hash }
    }
  end

end