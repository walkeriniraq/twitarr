module App
  module Announcements
    actionize!

    post 'submit' do
      return render_json status: 'Not logged in.' if @session[:username].nil?
      return render_json status: 'Announcements can only be created by admins.' unless @session[:is_admin]
      r = server.redis_connection
      post = Message.new(username: @session[:username], message: @params[:message], post_time: Time.now)
      r.lpush "announcements", post.to_json
      render_json status: 'ok'
    end

    get 'list' do
      r = server.redis_connection
      data = r.lrange "announcements", 0, 20
      return render_json list: [{ message: 'No announcements!'}] if data.empty?
      data = data.map { |x| JSON.parse(x.to_s) }
      render_json list: data
    end

  end
end