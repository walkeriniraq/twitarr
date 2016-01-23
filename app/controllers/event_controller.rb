class EventController < ApplicationController

  def page
    per_page = 20
    offset = params[:page].to_i || 0

    events = Event.offset(offset * per_page).limit(per_page).order_by(:start_time.desc)
    render_json events: events.map { |x| x.decorate.to_hash(current_username)}
  end

  def show
    event = Event.find(params[:id])
    render_json status: 'ok', event: event.decorate.to_hash
  end
end