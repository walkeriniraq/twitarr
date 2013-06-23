require_relative '../controller_helpers.rb'

module AnnouncementsController
  actionize!

  include ControllerHelpers

  post 'submit' do
    return login_required unless logged_in?
    return render_json status: 'Announcements can only be created by admins.' unless is_admin?
    redis = server.redis_connection
    post = Message.new_post(@params[:message], @session[:username])
    redis.lpush "announcements", post.to_json
    render_json status: 'ok'
  end

  get 'list' do
    redis = server.redis_connection
    data = redis.lrange "announcements", 0, 20
    return render_json list: [{ message: 'No announcements!' }] if data.empty?
    data = data.map { |x| JSON.parse(x.to_s) }
    render_json list: data
  end

end