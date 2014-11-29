class SeamailController < ApplicationController

  def index
    render_json seamail_meta: current_user.seamails.map { |x| x.decorate.to_meta_hash.merge!({is_unread: x.unread_users.andand.include?(current_username)}) }
  end

  def show
    seamail = Seamail.find(params[:id])
    was_unread = seamail.unread_users.include?(current_username)
    seamail.mark_as_read current_username
    render_json seamail:seamail.decorate.to_hash.merge!({is_unread: was_unread})
  end

  def create
    seamail = Seamail.create_new_seamail current_username, params[:users], params[:subject], params[:text]
    if seamail.valid?
      render_json seamail_meta: seamail.decorate.to_meta_hash.merge!({is_unread: seamail.unread_users.include?(current_username)})
    else
      render_json errors: seamail.errors.full_messages
    end
  end

  def new_message
    seamail = Seamail.find(params[:seamail_id])
    message = seamail.add_message current_username, params[:text]
    if message.valid?
      render_json seamail_message: message.decorate.to_hash.merge!({is_unread: seamail.unread_users.include?(current_username)})
    else
      render_json errors: message.errors.full_messages
    end
  end

  def recipients
    seamail = Seamail.find(params[:id])
    unless seamail.usernames.include? current_username
      render json: {errors: 'Must already be part of the Seamail to add recipients.'}, status: :forbidden
    end
    # this ensures that the logged in user is also specified
    usernames = Set.new([params[:users], current_username].flatten).to_a
    seamail.usernames = usernames
    seamail.reset_read current_username
    seamail.save!
    render json: {seamail_meta: seamail.decorate.to_meta_hash}
  end

end