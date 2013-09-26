class PostsController < ApplicationController

  TAG_FACTORY = lambda { |tag| Redis::SortedSet.new("System:tag_index:#{tag}") }

  def popular_index
    Redis::SortedSet.new('System:popular_posts_index')
  end

  def submit
    return render_json status: 'Not logged in.' unless logged_in?
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
    context = DeletePostContext.new post: post,
                                    tag_factory: TAG_FACTORY,
                                    popular_index: popular_index,
                                    object_store: object_store
    context.call
    render_json status: 'ok'
  end

  def favorite
    return login_required unless logged_in?
    post = object_store.get(Post, params[:id])
    context = LikePostContext.new post: post,
                                  post_likes: Redis::Set.new("System:post_likes:#{post.post_id}"),
                                  username: current_username,
                                  popular_index: popular_index
    context.call
    render_json status: 'ok'
  end

  def popular
    render_json status: 'ok', list: object_store.get(Post, popular_index[0, 20])
  end

  def list
    tag = if params[:username]
            user = object_store.get(User, params[:username])
            return render_json(status: 'Could not find user!') if user.nil?
            "@#{params[:username]}"
          else
            "@#{current_username}"
          end
    render_json status: 'ok', list: object_store.get(Post, TAG_FACTORY.call(tag)[0, 20])
  end

  def search
    render_json status: 'ok', list: object_store.get(Post, TAG_FACTORY.call("##{params[:term]}")[0, 20])
  end

end