require_relative '../controller_helpers.rb'

module PostsController
  actionize!

  include ControllerHelpers

  def database
    server.database
  end

  post 'submit' do
    return render_json status: 'Not logged in.' if @session[:username].nil?
    post = Message.new_post(@params[:message], @session[:username])
    database.submit_post post
    render_json status: 'ok'
  end

  get 'list' do
    # TODO: fix this
    #return render_json list: [{ message: 'No posts!' }] if data.empty?
    render_json list: database.post_list(0, 20)
  end

end