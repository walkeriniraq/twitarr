class SeamailController < ApplicationController

  def inbox_factory(redis)
    lambda { |user| redis.inbox_index user }
  end

  def submit
    return login_required unless logged_in?
    mail = Seamail.new from: current_username, to: params[:to], subject: params[:subject], text: params[:text]
    context = CreateSeamailContext.new seamail: mail,
                                       from_user_sent_index: redis.sent_mail_index(mail.from),
                                       inbox_index_factory: inbox_factory(redis),
                                       object_store: object_store
    context.call
    render_json status: 'ok'
  end

  def inbox
    return login_required unless logged_in?
    ids = redis.inbox_index(current_username).revrange(0, 50)
    list = object_store.get(Seamail, ids) || []
    render_json status: 'ok', list: list.map { |x| x.decorate.gui_hash }
  end

  def outbox
    return login_required unless logged_in?
    ids = redis.sent_mail_index(current_username)
    list = object_store.get(Seamail, ids) || []
    render_json status: 'ok', list: list.map { |x| x.decorate.gui_hash }
  end

end