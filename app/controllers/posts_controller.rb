class PostsController < ApplicationController

  TAG_FACTORY = lambda { |tag| Redis::SortedSet.new("System:tag_index:#{tag}") }

  def popular_index
    Redis::SortedSet.new('System:Popular_index')
  end

  def object_store
    RedisObjectStore.new
  end

  def submit
    return render_json status: 'Not logged in.' unless logged_in?
    # TODO: handle errors
    context = CreatePostContext.new user: User.new(current_username),
                                    post_text: params[:message],
                                    tag_factory: TAG_FACTORY,
                                    popular_index: popular_index,
                                    object_store: object_store
    context.call
    render_json status: 'ok'
  end

  def delete
    return login_required unless logged_in?
    post = object_store.get(Post, params[:id])
    return render_json status: 'Posts can only be deleted by their owners.' unless post.username == current_username || is_admin?
    # TODO: handle errors
    context = DeletePostContext.new post: post,
                                    tag_factory: TAG_FACTORY,
                                    popular_index: popular_index,
                                    object_store: object_store
    context.call
    render_json status: 'ok'
  end

  def favorite
    return login_required unless logged_in?
    Post.add_favorite params[:id], current_username
    render_json status: 'ok'
  end

  def popular
    render_json status: 'ok', list: Post.posts_hash(Post.popular, current_username)
  end

  def list
    if params[:username]
      user = User.get(params[:username])
      return render_json(status: 'Could not find user!') if user.nil?
      return render_json(status: 'ok', list: Post.posts_hash(Post.tagged("@#{params[:username]}"), current_username))
    end
    render_json status: 'ok', list: Post.posts_hash(Post.tagged("@#{current_username}"), current_username)
  end

  def search
    render_json status: 'ok', list: Post.posts_hash(Post.tagged("##{params[:term]}") + Post.tagged("@#{params[:term]}"), current_username)
  end


end