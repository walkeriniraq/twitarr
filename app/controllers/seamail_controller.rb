class SeamailController < ApplicationController

  def new
    return login_required unless logged_in?
    context = ValidateUserListContext.new list: params[:to],
                                          user_set: redis.users
    list = context.call
    return render_json(status: 'To names are not valid', names: context.validation) if list == nil
    TwitarrDb.create_seamail current_username, list, params[:subject], params[:text]
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

  def archive
    return login_required unless logged_in?
    ids = redis.archive_mail_index(current_username).revrange(0, 50)
    list = redis.seamail_store.get(ids) || []
    render_json status: 'ok', list: list.map { |x| x.decorate.gui_hash }
  end

  def do_archive
    return login_required unless logged_in?
    seamail = redis.seamail_store.get(params[:id])
    context = ArchiveSeamailContext.new seamail: seamail,
                                        username: current_username,
                                        inbox_index: redis.inbox_index(current_username),
                                        archive_index: redis.archive_mail_index(current_username)
    context.call
    render_json status: 'ok'
  end

end