require 'csv'
class API::V2::EventController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_filter :login_required, :only => [:create, :destroy, :update, :signup, :destroy_signup, :favorite, :destroy_favorite]
  before_filter :fetch_event, :except => [:index, :create, :csv]

  def login_required
    head :unauthorized unless logged_in? || valid_key?(params[:key])
  end

  def fetch_event
    begin
      @event = Event.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      render status: 404, json: {status: 'Not found', id: params[:id], error: "Event by id #{params[:id]} is not found."}
    end
  end

  def ical
    @event = Event.find(params[:id])
    # Yes this is based off vcard. They're really similar!
    cal_string = "BEGIN:VCALENDAR\n"
    cal_string << "VERSION:2.0\n"
    cal_string << "PRODID:-//twitarrteam/twitarr//NONSGML v1.0//END\n"

    cal_string << "BEGIN:VEVENT\n"
    cal_string << "UID:#{@event.id}@twitarr.local\n"
    cal_string << "DTSTAMP:#{@event.start_time.strftime('%Y%m%dT%H%M%S')}\n"
    cal_string << "ORGANIZER:CN=JOCO Cruise\n"
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

  def favorite
    @event = Event.find(params[:id])
    render json: [{error: 'You have already favorited this event'}], status: :forbidden and return if @event.favorites.include? current_username
    @event.favorites << current_username
    @event.save
    if @event.valid?
      render_json event: @event.decorate.to_hash(current_username)
    else
      render_json errors: @event.errors.full_messages
    end
  end

  def destroy_favorite
    @event = Event.find(params[:id])
    render json: [{error: 'You have not favorited this event'}], status: :forbidden and return if !@event.favorites.include? current_username
    @event.favorites = @event.favorites.delete current_username
    @event.save
    if @event.valid?
      render_json event: @event.decorate.to_hash(current_username)
    else
      render_json errors: @event.errors.full_messages
    end
  end

  def index
    sort_by = (params[:sort_by] || 'start_time').to_sym
    order = (params[:order] || 'desc').to_sym
    query = Event.all.order_by([sort_by, order])
    filtered_query = query.map { |x| x.decorate.to_hash current_username }
    result = [status: 'ok', total_count: filtered_query.length, events: filtered_query]
    respond_to do |format|
      format.json { render json: result }
      format.xml { render xml: result }
    end
  end

  def show
    @event = Event.find(params[:id])
    respond_to do |format|
      format.json { render json: @event.decorate.to_hash }
      format.xml { render xml: @event.decorate.to_hash }
    end
  end

end
