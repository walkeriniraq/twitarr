require_relative '../controller_helpers.rb'

module PostsController
  actionize!
  include ControllerHelpers

  post 'submit' do
    return render_json status: 'Not logged in.' if @session[:username].nil?
    post = Post.new_post(@params[:message], @session[:username])
    post.save
    render_json status: 'ok'
  end

  get 'list' do
    # TODO: fix this
    #return render_json list: [{ message: 'No posts!' }] if data.empty?
    render_json list: Post.recent
  end

  get 'mine' do
    render_json list: Post.tagged("@#{@session[:username]}")
  end

end