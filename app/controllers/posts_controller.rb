class PostsController < ApplicationController

  def submit
    return login_required unless logged_in?
    context = CreatePostContext.new user: current_username,
                                    post_text: params[:message],
                                    tag_factory: tag_factory(redis),
                                    popular_index: redis.popular_posts_index,
                                    object_store: object_store
    context.call
    render_json status: 'ok'
  end

  def delete
    return login_required unless logged_in?
    post = object_store.get(Post, params[:id])
    return render_json status: 'Posts can only be deleted by their owners.' unless post.username == current_username || is_admin?
    context = DeletePostContext.new post: post,
                                    tag_factory: tag_factory(redis),
                                    popular_index: redis.popular_posts_index,
                                    object_store: object_store
    context.call
    render_json status: 'ok'
  end

  def favorite
    return login_required unless logged_in?
    post = object_store.get(Post, params[:id])
    context = LikePostContext.new post: post,
                                  post_likes: redis.post_favorites_set(post.post_id),
                                  username: current_username,
                                  popular_index: redis.popular_posts_index
    context.call
    render_json status: 'ok'
  end

  def popular
    render_json status: 'ok', list: post_hash(redis.popular_posts_index.revrange(0, 20))
  end

  def list
    tag = if params[:username]
            user = object_store.get(User, params[:username])
            return render_json(status: 'Could not find user!') if user.nil?
            "@#{params[:username]}"
          else
            "@#{current_username}"
          end
    render_json status: 'ok', list: post_hash(redis.tag_index(tag).revrange(0, 20))
  end

  def search
    render_json status: 'ok', list: post_hash(redis.tag_index(params[:term]).revrange(0, 20))
  end

  def post_hash(ids)
    favorites = UserFavorites.new(redis, current_username, ids)
    object_store.get(Post, ids).map { |x| x.decorate.gui_hash(favorites) }
  end

end