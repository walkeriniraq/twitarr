require_relative '../controller_helpers.rb'

module AnnouncementsController
  actionize!

  include ControllerHelpers

  post 'submit' do
    return login_required unless logged_in?
    return render_json status: 'Announcements can only be created by admins.' unless is_admin?
    post = Announcement.new_post(@params[:message], current_username)
    post.save
    render_json status: 'ok'
  end

  post 'delete' do
    return login_required unless logged_in?
    return render_json status: 'Announcements can only be deleted by admins.' unless is_admin?
    Announcement.delete(@params[:id])
    render_json status: 'ok'
  end

  get 'list' do
    render_json status: 'ok', list: Announcement.recent(0, 20)
  end

end