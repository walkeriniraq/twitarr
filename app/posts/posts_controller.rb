require_relative '../controller_helpers.rb'

module PostsController
  actionize!

  include ControllerHelpers

  post 'submit' do
    return render_json status: 'Not logged in.' if @session[:username].nil?
    redis = server.redis_connection
    post = Message.new_post(@params[:message], @session[:username])
    redis.lpush "posts", post.to_json
    render_json status: 'ok'
  end

  get 'list' do
    redis = server.redis_connection
    data = redis.lrange "posts", 0, 20
    return render_json list: [{ message: 'No posts!' }] if data.empty?
    data = data.map { |x| JSON.parse(x.to_s) }
    render_json list: data
  end

end