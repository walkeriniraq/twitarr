class PostsController < ApplicationController

  def submit
    return login_required unless logged_in?
    context = CreatePostContext.new user: current_username,
                                    tag_factory: tag_factory(redis),
                                    popular_index: redis.popular_posts_index,
                                    post_index: redis.post_index,
                                    post_store: redis.post_store
    context.call params[:message]
    render_json status: 'ok'
  end

  def delete
    return login_required unless logged_in?
    post = object_store.get(Post, params[:id])
    return render_json status: 'Posts can only be deleted by their owners.' unless post.username == current_username || is_admin?
    context = DeletePostContext.new post: post,
                                    tag_factory: tag_factory(redis),
                                    popular_index: redis.popular_posts_index,
                                    post_index: redis.post_index,
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
    favorites = UserFavorites.new(redis, current_username, [ post.post_id ])
    render_json status: 'ok', sentence: post.decorate.liked_sentence(favorites)
  end

  def popular
    render_json status: 'ok', list: post_hash(redis.popular_posts_index.revrange(0, 50))
  end

  def all
    #render_json status: 'ok', list: post_hash(redis.post_index.revrange(0, 50))
    context = PostsListContext.new announcement_list: redis.announcements_list,
                                   posts_index: redis.post_index.revrange(0, 50),
                                   post_store: redis.post_store
    render_json status: 'ok', list: post_hash(context.call)
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
    render_json status: 'ok', list: post_hash(redis.tag_index("##{params[:term]}").revrange(0, 20))
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