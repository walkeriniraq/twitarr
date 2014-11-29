class SeamailController < ApplicationController

  def index
    render_json seamail_meta: current_user.seamails.map { |x| x.decorate.to_meta_hash }
  end

  def show
    seamail = Seamail.find(params[:id])
    seamail.mark_as_read current_username
    render_json seamail:seamail.decorate.to_hash
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