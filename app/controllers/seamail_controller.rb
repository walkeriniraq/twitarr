class SeamailController < ApplicationController

  def submit
    return login_required unless logged_in?
    TwitarrDb.create_seamail current_username, params[:to], params[:subject], params[:text]
    render_json status: 'ok'
  end

  def inbox
    return login_required unless logged_in?
    ids = redis.inbox_index(current_username).revrange(0, 50)
    list = redis.seamail_store.get(ids) || []
    render_json status: 'ok', list: list.map { |x| x.decorate.gui_hash }
  end

  def outbox
    return login_required unless logged_in?
    ids = redis.sent_mail_index(current_username).revrange(0, 50)
    list = redis.seamail_store.get(ids) || []
    render_json status: 'ok', list: list.map { |x| x.decorate.gui_hash }
  end

end