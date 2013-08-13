class PostsController < ApplicationController
  def submit
    return render_json status: 'Not logged in.' unless logged_in?
    post = Post.new_post(params[:message], current_username)
    post.save
    render_json status: 'ok'
  end

  def delete
    return login_required unless logged_in?
    unless is_admin?
      post = Post.find(params[:id])
      return render_json status: 'Posts can only be deleted by their owners.' unless post.username == current_username
    end
    Post.delete(params[:id])
    render_json status: 'ok'
  end

  def favorite
    return login_required unless logged_in?
    Post.add_favorite params[:id], current_username
    render_json status: 'ok'
  end

  def popular
    render_json status: 'ok', list: Post.popular.map { |x| x.ui_json_hash(current_username) }
  end

  def list
    if params[:username]
      user = User.get(params[:username])
      return render_json(status: 'Could not find user!') if user.nil?
      return render_json(status: 'ok', list: Post.tagged("@#{params[:username]}").map { |x| x.ui_json_hash(current_username) })
    end
    render_json status: 'ok', list: Post.tagged("@#{current_username}").map { |x| x.ui_json_hash(current_username) }
  end

  def search
    render_json status: 'ok',
                list: Post.tagged("##{params[:term]}").map { |x| x.ui_json_hash(current_username) } +
                    Post.tagged("@#{params[:term]}").map { |x| x.ui_json_hash(current_username) }
  end



end