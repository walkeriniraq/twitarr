require 'csv'
class API::V2::EventController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_filter :login_required, :only => [:create, :destroy, :update, :signup, :destroy_signup, :favorite, :destroy_favorite]
  before_filter :fetch_event, :except => [:index, :create, :csv]

  def login_required
    head :unauthorized unless logged_in? || valid_key?(params[:key])
  end

  def is_event_allowed(ev)
    #logger.debug("is_event_allowed: " + ev.decorate.to_hash.inspect)
    #logger.debug("valid key? " + (valid_key?(params[:key]) ? "true" : "false"))
    #logger.debug("official=" + (ev.official ? "true" : "false"))
    return true if (ev.official)
    #logger.debug("shared=" + (ev.shared ? "true" : "false"))
    return true if (ev.shared)
    #logger.debug("author=" + ev.author + ", current_username=" + (current_username == nil ? "nil" : current_username))
    return true if (ev.author == current_username)
    return false
  end

  def fetch_event
    begin
      @event = Event.find(params[:id])
      head :unauthorized and return if !is_event_allowed(@event)
    rescue Mongoid::Errors::DocumentNotFound
      render status: 404, json: {status:'Not found', id: params[:id], error: "Event by id #{params[:id]} is not found."}
    end
  end

  def csv
    sort_by = (params[:sort_by] || 'start_time').to_sym
    order = (params[:order] || 'desc').to_sym
    source = params[:source] || 'all'
    case source
    when 'all'
      query = Event.all.order_by([sort_by, order]).select { |ev| is_event_allowed(ev) }
    when 'own'
      events = Event.any_in(favorites: current_username).map {|x|x}
      events = events.concat(Event.any_in(signups: current_username).map {|x|x})
      events = events.concat(Event.where(author: current_username).map {|x|x}).uniq
      query = events.sort {|a,b| a.start_time <=> b.start_time }
    end
    #puts query
    result = CSV.generate do |csv|
      csv << ["id", "Title", "Author", "Display Name", "Location", "Start Time", "End Time", "Description", "Official?", "Shared?", "Signups", "Maximum Signups", "Favorites"]
      query.each do |q|
        csv << [
          q.id,
          q.title,
          q.author,
          User.display_name_from_username(q.author),
          q.location,
          q.start_time,
          q.end_time,
          q.description,
          q.official,
          q.shared,
          q.signups.join(", "),
          q.max_signups,
          q.favorites.join(", ")
        ]
      end
    end
    send_data result, type: "text/csv", disposition: "attachment; filename=events.csv"
  end


  def ical
    # Yes this is based off vcard. They're really similar!
    cal_string = "BEGIN:VCALENDAR\n"
    cal_string << "VERSION:2.0\n"
    cal_string << "PRODID:-//twitarrteam/twitarr//NONSGML v1.0//END\n"

    cal_string << "BEGIN:VEVENT\n"
    cal_string << "UID:#{@event.id}@twitarr.local\n"
    cal_string << "DTSTAMP:#{@event.start_time.strftime('%Y%m%dT%H%M%S')}\n"
    cal_string << "ORGANIZER:CN=#{User.display_name_from_username(@event.author)}\n"
    cal_string << "DTSTART:#{@event.start_time.strftime('%Y%m%dT%H%M%S')}\n"
    cal_string << "DTEND:#{@event.end_time.strftime('%Y%m%dT%H%M%S')}\n" unless @event.end_time.blank?
    cal_string << "SUMMARY:#{@event.title}\n"
    cal_string << "DESCRIPTION:#{@event.description}\n"
    cal_string << "LOCATION:#{@event.location}\n"
    cal_string << "END:VEVENT\n"

    cal_string << "END:VCALENDAR"
    headers['Content-Disposition'] = "inline; filename=\"#{@event.title.parameterize('_')}.ics\""

    render body: cal_string, content_type: 'text/vcard', layout: false
  end

  def signup
    render json:[{error:'Max signups has already been reached'}], status: :forbidden and return if (!!@event.signups and !!@event.max_signups) and @event.signups.length >= @event.max_signups
    render json:[{error:'You have already signed up for this event'}], status: :forbidden and return if (!!@event.signups and !!@event.max_signups) and @event.signups.include? current_username
    @event.signups << current_username
    @event.save
    if @event.valid?
      render_json event: @event.decorate.to_hash
    else
      render_json errors: @event.errors.full_messages
    end
  end

  def destroy_signup
    render json:[{error:'You have not signed up for this event'}], status: :forbidden and return if !@event.signups.include? current_username
    @event.signups = @event.signups - [current_username]
    @event.save
    if @event.valid?
      render_json event: @event.decorate.to_hash
    else
      render_json errors: @event.errors.full_messages
    end
  end

  def favorite
    render json:[{error:'You have already favorited this event'}], status: :forbidden and return if @event.favorites.include? current_username
    @event.favorites << current_username
    @event.save
    if @event.valid?
      render_json event: @event.decorate.to_hash
    else
      render_json errors: @event.errors.full_messages
    end
  end

  def destroy_favorite
    render json:[{error:'You have not favorited this event'}], status: :forbidden and return if !@event.favorites.include? current_username
    @event.favorites = @event.favorites - [current_username]
    @event.save
    if @event.valid?
      render_json event: @event.decorate.to_hash
    else
      render_json errors: @event.errors.full_messages
    end
  end

  def index
    sort_by = (params[:sort_by] || 'start_time').to_sym
    order = (params[:order] || 'desc').to_sym
    query = Event.all.order_by([sort_by, order]).select { |ev| is_event_allowed(ev) }
    filtered_query = query.map(&:decorate).map(&:to_hash)
    result = [status: 'ok', total_count: filtered_query.length, events: filtered_query]
    respond_to do |format|
      format.json { render json: result }
      format.xml { render xml: result }
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @event.decorate.to_hash }
      format.xml { render xml: @event.decorate.to_hash }
    end
  end

  def create
    render json:[{error:'You must be admin to create official events!'}], status: :forbidden and return if (params[:official] and !is_admin?)
    event = Event.create_new_event(current_username, params[:title], params[:start_time],
      :location => params[:location],
      :description => params[:description],
      :shared => params[:shared],
      :official => params[:official],
      :end_time => params[:end_time],
      :max_signups => params[:max_signups]
    )
    if event.valid?
      render_json event: event.decorate.to_hash
    else
      render_json errors: event.errors.full_messages
    end
  end

  def update
    render json:[{error:'Event hash missing from data'}], status: :forbidden and return unless (params.has_key? :event)
    event = params[:event]
    render json:[{error:'You must be admin to create official events!'}], status: :forbidden and return if (!!event[:official] and !is_admin?)
    if event[:author] != @event.author
      render json:[{error:'Unable to modify event.  Author cannot be changed!'}], status: :bad_request
      return
    end

    unless @event.author == current_username or is_admin?
      render json: [{error:"You may not modify other users' posts"}], status: :forbidden
      return
    end

    if (event[:official] or @event.official) and !is_admin?
      render json: [{error:"You must be admin to modify official events!"}], status: :forbidden
      return
    end
    @event.title = event[:title] if event.has_key? :title
    @event.description = event[:description] if event.has_key? :description
    @event.location = event[:location] if event.has_key? :location
    @event.start_time = event[:start_time] if event.has_key? :start_time
    @event.end_time = event[:end_time] if event.has_key? :end_time
    @event.max_signups = event[:max_signups] if event.has_key? :max_signups
    @event.official = event[:official] if event.has_key? :official
    @event.shared = event[:shared] if event.has_key? :shared

    @event.save
    if @event.valid?
      render_json events: @event.decorate.to_hash
    else
      render_json errors: @event.errors.full_messages
    end
  end

  def destroy
    unless @event.author == current_username or is_admin?
      err = [{error:"You may not delete other users' posts"}]
      return respond_to do |format|
        format.json { render json: err, status: :forbidden }
        format.xml { render xml: err, status: :forbidden }
      end
    end
    respond_to do |format|
      if @event.destroy
        format.json { head :no_content, status: :ok }
        format.xml { head :no_content, status: :ok }
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
        format.xml { render xml: @event.errors, status: :unprocessable_entity }
      end
    end
  end
end
