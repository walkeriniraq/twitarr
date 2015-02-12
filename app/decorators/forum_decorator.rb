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
        timestamp: last_post,
        last_post_page: posts.count / 10
    }
    unless user.nil?
      count = post_count_since(user.last_forum_view(id.to_s))
      ret[:new_posts] = "#{count} <b class=\"highlight\">new</b>" if count > 0
      ret[:last_post_page] = count / 10 if count > 0
    end
    ret
  end

  def to_hash(page,user = nil)
    per_page = 10
    offset = page * per_page
    next_page = nil
    prev_page = nil

    next_page = page + 1 if posts.offset((page + 1) * per_page).limit(per_page).to_a.count != 0
    prev_page = page - 1 unless (offset - 1) < 0
    if user.nil?
      {
          id: id.to_s,
          subject: subject,
          posts: posts.limit(per_page).offset(offset).map { |x| x.decorate.to_hash },
          next_page: next_page,
          prev_page: prev_page
      }
    else
      last_view = user.last_forum_view(id.to_s)
      {
          id: id.to_s,
          subject: subject,
          posts: posts.limit(per_page).offset(offset).map { |x| x.decorate.to_hash(last_view) },
          latest_read: last_view,
          next_page: next_page,
          prev_page: prev_page
      }
    end
  end

end