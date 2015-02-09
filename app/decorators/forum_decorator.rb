class ForumDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::TextHelper

  def to_meta_hash(user = nil)
    ret = {
        id: id.to_s,
        subject: subject,
        last_post_username: posts.last.author,
        last_post_display_name: User.display_name_from_username(posts.last.author),
        posts: pluralize(post_count, 'post'),
        timestamp: last_post
    }
    unless user.nil?
      count = post_count_since(user.last_forum_view(id.to_s))
      ret[:new_posts] = pluralize(count, '<b class="highlight">new</b> post')  if count > 0
    end
    ret
  end

  def to_hash(user = nil)
    if user.nil?
      {
          id: id.to_s,
          subject: subject,
          posts: posts.map { |x| x.decorate.to_hash }
      }
    else
      last_view = user.last_forum_view(id.to_s)
      {
          id: id.to_s,
          subject: subject,
          posts: posts.map { |x| x.decorate.to_hash(last_view) },
          latest_read: last_view
      }
    end
  end

end