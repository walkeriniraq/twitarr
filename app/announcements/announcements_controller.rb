require_relative '../controller_helpers.rb'

module AnnouncementsController
  actionize!

  include ControllerHelpers

  def database
    server.database
  end

  post 'submit' do
    return login_required unless logged_in?
    return render_json status: 'Announcements can only be created by admins.' unless is_admin?
    post = Message.new_post(@params[:message], @session[:username])
    database.submit_announcement post
    render_json status: 'ok'
  end

  get 'list' do
    # TODO: fix this too
    #return render_json list: [{ message: 'No announcements!' }] if data.empty?
    render_json list: database.announcement_list(0, 20)
  end

end