class AnnouncementsController < ApplicationController

  def submit
    return login_required unless logged_in?
    #context = CreateAnnouncementContext.new user: current_username,
    #                                        post_text: params[:message],
    #                                        tag_factory: tag_factory(redis),
    #                                        announcement_index: redis.announcements_index,
    #                                        object_store: object_store
    context = CreateAnnouncementContext.new list: [],
                                            cache: []
    context.call(current_username, params[:message], 0)
    render_json status: 'ok'
  end

  def delete
    # TODO: need context
    #return login_required unless logged_in?
    #return render json: { status: 'Announcements can only be created by admins.' } unless is_admin?
    #Announcement.delete(params[:id])
    render json: { status: 'ok' }
  end

  #def list
  #  list = object_store.get(Post, redis.announcements_index.revrange(0, 20)).map { |x| x.decorate.announcement_hash }
  #  render_json status: 'ok', list: list
  #end

end