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
                                  popular_index: redis.popular_posts_index
    context.call
    favorites = UserFavorites.new(redis, current_username, [post.post_id])
    render_json status: 'ok', sentence: post.decorate.liked_sentence(favorites)
  end

  def popular
    posts, announcements = filter_direction redis.popular_posts_index, redis.announcements, params[:dir], params[:time]
    context = EntryListContext.new announcement_list: announcements,
                                   posts_index: posts,
                                   post_store: redis.post_store
    list = context.call
    render_json status: 'ok', list: list_output(list)
  end

  def all
    posts, announcements = filter_direction redis.post_index, redis.announcements, params[:dir], params[:time]
    context = EntryListContext.new announcement_list: announcements,
                                   posts_index: posts,
                                   post_store: redis.post_store
    list = context.call
    render_json status: 'ok', list: list_output(list)
  end

  def feed
    return login_required unless logged_in?
    posts, announcements = filter_direction redis.feed_index(current_username), redis.announcements, params[:dir], params[:time]
    context = EntryListContext.new announcement_list: announcements,
                                   posts_index: posts,
                                   post_store: redis.post_store
    list = context.call
    render_json status: 'ok', list: list_output(list)
  end

  def list
    tag = if params[:username]
            user = redis.user_store.get(params[:username])
            return render_json(status: 'Could not find user!') if user.nil?
            "@#{params[:username]}"
          else
            "@#{current_username}"
          end
    case
      when params[:dir] == 'before'
        posts = redis.tag_index(tag).revrangebyscore(
            params[:time].to_f - 0.000001,
            0,
            limit: EntryListContext::PAGE_SIZE
        )
      when params[:dir] == 'after'
        posts = redis.tag_index(tag).rangebyscore(
            params[:time].to_f + 0.000001,
            Time.now.to_f,
            limit: EntryListContext::PAGE_SIZE
        )
      else
        posts = redis.tag_index(tag).revrange(0, EntryListContext::PAGE_SIZE)
    end
    context = EntryListContext.new posts_index: posts,
                                   post_store: redis.post_store
    render_json status: 'ok', list: list_output(context.call)
  end

  def search
    case
      when params[:dir] == 'before'
        posts = redis.tag_index("##{params[:term]}").revrangebyscore(
            params[:time].to_f - 0.000001,
            0,
            limit: EntryListContext::PAGE_SIZE
        )
      when params[:dir] == 'after'
        posts = redis.tag_index("##{params[:term]}").rangebyscore(
            params[:time].to_f + 0.000001,
            Time.now.to_f,
            limit: EntryListContext::PAGE_SIZE
        )
      else
        posts = redis.tag_index("##{params[:term]}").revrange(0, EntryListContext::PAGE_SIZE)
    end
    context = EntryListContext.new posts_index: posts,
                                   post_store: redis.post_store
    render_json status: 'ok', list: list_output(context.call)
  end

  def list_output(list)
    ids = list.reduce([]) { |list, x| list << x.entry_id if x.type == :post; list }
    favorites = UserFavorites.new(redis, current_username, ids)
    list.map { |x| x.decorate.gui_hash_with_favorites(favorites) }
  end

  def filter_direction(posts, announcements, direction, time)
    case
      when params[:dir] == 'before'
        from = params[:time].to_f - 0.000001
        to = 0
        return posts.revrangebyscore(from, to, limit: EntryListContext::PAGE_SIZE),
            announcements.get(params[:time].to_f - 0.000001, 0, EntryListContext::PAGE_SIZE)
      when params[:dir] == 'after'
        from = params[:time].to_f + 0.000001
        to = Time.now.to_f
        return posts.rangebyscore(from, to, limit: EntryListContext::PAGE_SIZE),
            announcements.get(from, to, EntryListContext::PAGE_SIZE)
      else
        return posts.revrange(0, EntryListContext::PAGE_SIZE),
            announcements.get(Time.now.to_f, 0, EntryListContext::PAGE_SIZE)
    end
  end

  def post_hash(posts)
    favorites = UserFavorites.new(redis, current_username, posts.map { |x| x.post_id })
    posts.map(&:decorate).map do |x|
      if x.respond_to? :gui_hash_with_favorites
        x.gui_hash_with_favorites(favorites)
      else
        x.gui_hash
      end
    end
  end

end