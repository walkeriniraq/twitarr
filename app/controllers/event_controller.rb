class EventController < ApplicationController

  def page
    per_page = 20
    offset = params[:page].to_i || 0

    events = Event.offset(offset * per_page).limit(per_page).order_by(:start_time.asc)

    next_page = offset + 1
    next_page = nil if Event.offset((offset + 1) * per_page).limit(per_page).order_by(:start_time.asc).to_a.count ==  0
    prev_page = offset - 1
    prev_page = nil if prev_page < 0

    render_json events: events.map { |x| x.decorate.to_hash(current_username)}, next_page: next_page, prev_page: prev_page
  end
end