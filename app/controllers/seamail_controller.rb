class SeamailController < ApplicationController

  def index
    render_json seamail_meta: current_user.seamails.map { |x| x.decorate.to_meta_hash }
  end

  def show
    render_json seamail: Seamail.find(params[:id]).decorate.to_hash
  end

  def create
    seamail = Seamail.create_new_seamail current_username, params[:users], params[:subject], params[:text]
    if seamail.valid?
      render_json seamail_meta: seamail.decorate.to_meta_hash
    else
      render_json errors: seamail.errors.full_messages
    end
  end

  def new_message
    seamail = Seamail.find(params[:seamail_id])
    message = seamail.add_message current_username, params[:text]
    if message.valid?
      render_json seamail_message: message.decorate.to_hash
    else
      render_json errors: message.errors.full_messages
    end
  end

  # def new
  #   return read_only_mode if Twitarr::Application.config.read_only
  #   return login_required unless logged_in?
  #   context = ValidateUserListContext.new list: params[:to],
  #                                         user_set: redis.users
  #   list = context.call
  #   return render_json(status: 'To names are not valid', names: context.validation) if list == nil
  #   TwitarrDb.create_seamail current_username, list, params[:subject], params[:text]
  #   render_json status: 'ok'
  # end
  #
  # def inbox
  #   return login_required unless logged_in?
  #   ids = redis.inbox_index(current_username).revrange(0, 50)
  #   list = redis.seamail_store.get(ids) || []
  #   render_json status: 'ok', list: list.map { |x| x.decorate.gui_hash }
  # end
  #
  # def outbox
  #   return login_required unless logged_in?
  #   ids = redis.sent_mail_index(current_username).revrange(0, 50)
  #   list = redis.seamail_store.get(ids) || []
  #   render_json status: 'ok', list: list.map { |x| x.decorate.gui_hash }
  # end
  #
  # def archive
  #   return login_required unless logged_in?
  #   ids = redis.archive_mail_index(current_username).revrange(0, 50)
  #   list = redis.seamail_store.get(ids) || []
  #   render_json status: 'ok', list: list.map { |x| x.decorate.gui_hash }
  # end
  #
  # def do_archive
  #   return login_required unless logged_in?
  #   seamail = redis.seamail_store.get(params[:id])
  #   context = ArchiveSeamailContext.new seamail: seamail,
  #                                       username: current_username,
  #                                       inbox_index: redis.inbox_index(current_username),
  #                                       archive_index: redis.archive_mail_index(current_username)
  #   context.call
  #   render_json status: 'ok'
  # end
  #
  # def unarchive
  #   return login_required unless logged_in?
  #   seamail = redis.seamail_store.get(params[:id])
  #   context = UnarchiveSeamailContext.new seamail: seamail,
  #                                       username: current_username,
  #                                       inbox_index: redis.inbox_index(current_username),
  #                                       archive_index: redis.archive_mail_index(current_username)
  #   context.call
  #   render_json status: 'ok'
  # end

end