require_relative '../controller_helpers.rb'

module AnnouncementsController
  actionize!

  include ControllerHelpers

  post 'submit' do
    return login_required unless logged_in?
    return render_json status: 'Announcements can only be created by admins.' unless is_admin?
    post = Announcement.new_post(@params[:message], @session[:username])
    post.save
    render_json status: 'ok'
  end

  get 'list' do
    # TODO: fix this too
    #return render_json list: [{ message: 'No announcements!' }] if data.empty?
    render_json list: Announcement.recent(0, 20)
  end

end