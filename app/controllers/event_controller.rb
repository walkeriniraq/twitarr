class EventController < ApplicationController
  def mine
    day = Date.parse params[:day]
    events = Event.where(favorites: current_username).where(:start_time.gte => day).where(:start_time.lt => day + 1).order_by(:start_time.asc)
    render_json events: events.map { |x| x.decorate.to_meta_hash(current_username) }
  end

  def all
    day = Date.parse params[:day]
    events = Event.where(:start_time.gte => day).where(:start_time.lt => day + 1).order_by(:start_time.asc)
    render_json events: events.map { |x| x.decorate.to_meta_hash(current_username) }
  end

  # def past
  #   per_page = 20
  #   offset = params[:page].to_i || 0
  #
  #   events = Event.where(:shared => true).where(:start_time.lt => DateTime.now).offset(offset * per_page).limit(per_page).order_by(:start_time.desc)
  #   next_page = offset + 1
  #   next_page = nil if Event.where(:shared => true).where(:start_time.lt => DateTime.now).offset((offset + 1) * per_page).limit(per_page).order_by(:start_time.desc).to_a.count == 0
  #   prev_page = offset - 1
  #   prev_page = nil if prev_page < 0
  #
  #   render_json events: events.map { |x| x.decorate.to_hash(current_username) }, next_page: next_page, prev_page: prev_page
  # end

  def create
    render json: [{error: 'Only admins can create events.'}], status: :ok and return if (!is_admin?)
    event = Event.create_new_event(current_username, params[:title], Time.parse(params[:start_time]),
                                   :location => params[:location],
                                   :description => params[:description],
                                   :end_time => params[:end_time]
    )
    if event.save
      render_json event: event.decorate.to_hash
    else
      render_json errors: event.errors.full_messages
    end
  end

  def show
    return unless logged_in?
    render json: Event.find(params[:id]).decorate.to_hash(current_username)
  end

  def update
    render json: {status: 'error', error: ['Only admins can modify events.']} and return unless is_admin?
    @event = Event.find(params[:id])

    @event.title = params[:title] if params.has_key? :title
    @event.description = params[:description] if params.has_key? :description
    @event.location = params[:location] if params.has_key? :location
    @event.start_time = Time.parse(params[:start_time]) if params.has_key? :start_time
    @event.end_time = Time.parse(params[:end_time]) unless params[:end_time].blank?

    if @event.save
      render_json events: @event.decorate.to_hash(current_username)
    else
      render_json errors: @event.errors.full_messages
    end
  end

  def destroy
    @event = Event.find(params[:id])
    render json: {status: :error, errors: ['Only admins can delete events.']} and return if (!is_admin?)
    if @event.destroy
      render_json status: :ok
    else
      render_json status: :error, error: @event.errors
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
        events = Event.any_in(favorites: current_username).map { |x| x }
        events = events.concat(Event.any_in(signups: current_username).map { |x| x })
        events = events.concat(Event.where(author: current_username).map { |x| x }).uniq
        query = events.sort { |a, b| a.start_time <=> b.start_time }
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

  def follow
    return unless logged_in!
    event = Event.find(params[:id])
    event.follow current_username
    if event.save
      render_json status: 'ok'
    else
      render_json status: 'error', errors: event.errors
    end
  end

  def unfollow
    return unless logged_in!
    event = Event.find(params[:id])
    event.unfollow current_username
    if event.save
      render_json status: 'ok'
    else
      render_json status: 'error', errors: event.errors
    end
  end

end