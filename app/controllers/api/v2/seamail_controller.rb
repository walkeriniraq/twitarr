class API::V2::SeamailController < ApplicationController
  # noinspection RailsParamDefResolve
  skip_before_action :verify_authenticity_token

  before_filter :login_required
  before_filter :fetch_seamail, :only => [:show, :new_message, :recipients]

  before_filter :require_allow_modification!, only: [:create, :new_message]

  def login_required
    head :unauthorized unless logged_in? || valid_key?(params[:key])
  end

  def fetch_seamail
    @seamail = Seamail.find(params[:id])
    unless @seamail.usernames.include? current_username
      render json: {errors: 'Must already be part of the Seamail to view a seamail.'}, status: :forbidden
    end
  end


  def index
    extra_query = {}
    if params[:unread] && params[:unread].to_bool
      extra_query[:unread] = true
    end
    if params[:after]
      val = nil
      if params[:after] =~ /^\d+$/
        val = Time.at(params[:after].to_i / 1000.0)
      else
        val = DateTime.parse params[:after]
      end
      if val
        extra_query[:after] = val
      end
    end
    mails = current_user.seamails extra_query
    render_json seamail_meta: mails.map { |x| x.decorate.to_meta_hash.merge!({is_unread: x.unread_users.andand.include?(current_username)}) },
        last_checked: ((Time.now.to_f * 1000).to_i + 1)
  end

  def show
    was_unread = @seamail.unread_users.andand.include?(current_username)
    @seamail.mark_as_read current_username
    render_json seamail:@seamail.decorate.to_hash.merge!({is_unread: was_unread})
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
    message = @seamail.add_message current_username, params[:text]
    if message.valid?
      render_json seamail_message: message.decorate.to_hash.merge!({is_unread: @seamail.unread_users.include?(current_username)})
    else
      render_json errors: message.errors.full_messages
    end
  end

  def recipients
    # this ensures that the logged in user is also specified
    usernames = Set.new([params[:users], current_username].flatten).to_a
    @seamail.usernames = usernames
    @seamail.reset_read current_username
    @seamail.save!
    render json: {seamail_meta: @seamail.decorate.to_meta_hash}
  end

end