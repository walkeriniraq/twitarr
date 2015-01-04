class AnnouncementsController < ApplicationController

  # def submit
  #   return login_required unless logged_in?
  #   offset = params[:offset].to_i || 0
  #   context = CreateAnnouncementContext.new set: redis.announcements
  #   context.call(current_username, params[:message], offset)
  #   render_json status: 'ok'
  # end
  #
  # def delete
  #   # TODO: need context
  #   #return login_required unless logged_in?
  #   #return render json: { status: 'Announcements can only be created by admins.' } unless is_admin?
  #   #Announcement.delete(params[:id])
  #   render json: { status: 'ok' }
  # end

end