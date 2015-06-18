class API::V2::EventController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_filter :login_required, :only => [:create, :destroy, :updater]
  before_filter :fetch_event, :except => [:index, :create]

  def login_required
    head :unauthorized unless logged_in? || valid_key?(params[:key])
  end

  def fetch_event
    begin
      @event = Event.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      render status:404, json: {status:'Not found', id: params[:id], error: "Event by id #{params[:id]} is not found."}
    end
  end

  def index
    sort_by = (params[:sort_by] || 'start_time').to_sym
    order = (params[:order] || 'desc').to_sym
    query = Event.all.order_by([sort_by, order]).map(&:decorate).map(&:to_hash)
    result = [status: 'ok', total_count: query.length, events: query]
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
    event = Event.create_new_event(current_username, params[:title], params[:start_time], params[:location],
      :description => params[:description],
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
    unless (params[:event].keys - %w(description location start_time end_time max_signups)).empty?
      render json:[{error:'Unable to modify title or author fields'}], status: :bad_request
      return
    end

    unless @event.author == current_username or is_admin?
      err = [{error:"You can not modify other users' posts"}]
      render json: err, status: :forbidden
      return
    end
    event = params[:event]
    @event.description = event[:description] if event.has_key? :description
    @event.location = event[:location] if event.has_key? :location
    @event.start_time = event[:start_time] if event.has_key? :start_time
    @event.end_time = event[:end_time] if event.has_key? :end_time
    @event.max_signups = event[:max_signups] if event.has_key? :max_signups

    @event.save
    if @event.valid?
      render_json stream_post: @event.decorate.to_hash
    else
      render_json errors: @event.errors.full_messages
    end
  end

  def destroy
    unless @event.author == current_username or is_admin?
      err = [{error:"You can not delete other users' posts"}]
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