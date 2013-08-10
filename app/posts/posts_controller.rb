require_relative '../controller_helpers.rb'

module PostsController
  actionize!
  include ControllerHelpers

  post 'submit' do
    return render_json status: 'Not logged in.' unless logged_in?
    post = Post.new_post(@params[:message], current_username)
    post.save
    render_json status: 'ok'
  end

  post 'delete' do
    return login_required unless logged_in?
    unless is_admin?
      post = Post.find(@params[:id])
      return render_json status: 'Posts can only be deleted by their owners.' unless post.username == current_username
    end
    Post.delete(@params[:id])
    render_json status: 'ok'
  end

  get 'popular' do
    render_json status: 'ok', list: Post.popular.map { |x| x.ui_json_hash }
  end

  put 'favorite' do
    return login_required unless logged_in?
    Post.add_favorite @params[:id], current_username
    render_json status: 'ok'
  end

  get 'list' do
    return render_json(status: 'ok', list: Post.tagged("@#{@params[:username].downcase}")) if @params[:username]
    render_json status: 'ok', list: Post.tagged("@#{current_username}").map { |x| x.ui_json_hash }
  end

  get 'search' do
    list = Post.tagged("##{@params[:term].downcase}") + Post.tagged("@#{@params[:term]}").map { |x| x.ui_json_hash }
    render_json(list: list)
  end



end