class PostsController < ApplicationController

  def submit
    return login_required unless logged_in?
    TwitarrDb.create_post current_username, params[:message]
    render_json status: 'ok'
  end

  def delete
    return login_required unless logged_in?
    post = redis.post_store.get(params[:id])
    return render_json status: 'Posts can only be deleted by their owners.' unless post.username == current_username || is_admin?
    context = DeletePostContext.new post: post,
                                    tag_factory: tag_factory(redis),
                                    popular_index: redis.popular_posts_index,
                                    post_index: redis.post_index,
                                    post_store: redis.post_store
    context.call
    render_json status: 'ok'
  end

  def favorite
    return login_required unless logged_in?
    post = redis.post_store.get params[:id]
    context = LikePostContext.new post: post,
                                  post_likes: redis.post_favorites_set(post.post_id),
                                  username: current_username,
                                  popular_index: redis.popular_posts_index,
                                  user_feed: redis.feed_index(current_username)
    context.call
    favorites = UserFavorites.new(redis, current_username, [post.post_id])
    render_json status: 'ok', sentence: post.decorate.liked_sentence(favorites)
  end

  def popular
    posts = filter_direction_posts redis.popular_posts_index, params[:dir], params[:time]
    context = EntryListContext.new posts_index: posts,
                                   post_store: redis.post_store
    list = context.call
    render_json status: 'ok', list: list_output(list)
  end

  def all
    posts, announcements = filter_direction_both redis.post_index, redis.announcements, params[:dir], params[:time]
    context = EntryListContext.new announcement_list: announcements,
                                   posts_index: posts,
                                   post_store: redis.post_store
    list = context.call
    render_json status: 'ok', list: list_output(list)
  end

  def feed
    return login_required unless logged_in?
    posts, announcements, more = filter_direction_both redis.feed_index(current_username), redis.announcements, params[:dir], params[:time]
    context = EntryListContext.new announcement_list: announcements,
                                   posts_index: posts,
                                   post_store: redis.post_store
    list = context.call
    render_json status: 'ok', more: more, list: list_output(list)
  end

  def list
    tag = if params[:username]
            user = redis.user_store.get(params[:username])
            return render_json(status: 'Could not find user!') if user.nil?
            "@#{params[:username]}"
          else
            "@#{current_username}"
          end
    posts = filter_direction_posts redis.tag_index(tag), params[:dir], params[:time]
    context = EntryListContext.new posts_index: posts,
                                   post_store: redis.post_store
    render_json status: 'ok', list: list_output(context.call)
  end

  def search
    posts = filter_direction_posts redis.tag_index("##{params[:term]}"), params[:dir], params[:time]
    context = EntryListContext.new posts_index: posts,
                                   post_store: redis.post_store
    render_json status: 'ok', list: list_output(context.call)
  end

  def list_output(list)
    ids = list.reduce([]) { |list, x| list << x.entry_id if x.type == :post; list }
    favorites = UserFavorites.new(redis, current_username, ids)
    list.map { |x| x.decorate.gui_hash_with_favorites(favorites) }
  end

  def filter_direction_posts(posts, direction, time)
    case
      when direction == 'before'
        posts.revrangebyscore(
            time.to_f - 0.000001,
            0,
            limit: EntryListContext::PAGE_SIZE
        )
      when direction == 'after'
        posts.rangebyscore(
            time.to_f + 0.000001,
            Time.now.to_f,
            limit: EntryListContext::PAGE_SIZE
        )
      else
        posts.revrange(0, EntryListContext::PAGE_SIZE)
    end
  end

  def filter_direction_both(posts, announcements, direction, time)
    case
      when direction == 'before'
        from = time.to_f - 0.000001
        to = 0
        posts = posts.revrangebyscore(from, to, limit: EntryListContext::PAGE_SIZE + 1)
      when direction == 'after'
        from = time.to_f + 0.000001
        to = Time.now.to_f
        posts = posts.rangebyscore(from, to, limit: EntryListContext::PAGE_SIZE + 1)
      else
        from = Time.now.to_f
        to = 0
        posts = posts.revrange(0, EntryListContext::PAGE_SIZE + 1)
    end
    announcements = announcements.get(from, to, EntryListContext::PAGE_SIZE + 1)
    more = posts.count > EntryListContext::PAGE_SIZE || announcements.count > EntryListContext::PAGE_SIZE
    if more
      posts = posts.first(EntryListContext::PAGE_SIZE)
      announcements = announcements.first(EntryListContext::PAGE_SIZE)
    end
    return posts, announcements, more
  end

  def tag_autocomplete
    render_json status: 'ok', names: redis.tag_auto.query(params[:string])
  end

end