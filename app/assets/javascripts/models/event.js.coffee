Twitarr.EventMeta = Ember.Object.extend
  id: null
  author: null
  author_display_name: null
  title: null
  location: null
  start_time: null
  following: false

  follow: ->
    $.post("/event/#{@get('id')}/follow").then (data) =>
      if data.status is 'ok'
        @set('following', true)
      else
        alert data.error || data.errors.join("\n")

  unfollow: ->
    $.post("/event/#{@get('id')}/unfollow").done (data) =>
      if data.status is 'ok'
        @set('following', false)
      else
        alert data.error || data.errors.join("\n")

Twitarr.EventMeta.reopenClass
  mine: (page = 0) ->
    $.getJSON("/event/mine/#{page}").then (data) =>
      {events: @process_date_events(date) for date in data.events, has_next_page: data.has_next_page, page: page}

  mine_old: (page = 0) ->
    $.getJSON("/event/mine/old/#{page}").then (data) =>
      {events: @process_date_events(date) for date in data.events, has_next_page: data.has_next_page, has_prev_page: data.has_prev_page, page: page}

  all: (page = 0) ->
    $.getJSON("/event/all/#{page}").then (data) =>
      {events: @process_date_events(date) for date in data.events, has_next_page: data.has_next_page, has_prev_page: data.has_prev_page, page: page}

  old: (page = 0) ->
    $.getJSON("/event/all/old/#{page}").then (data) =>
      {events: @process_date_events(date) for date in data.events, has_next_page: data.has_next_page, has_prev_page: data.has_prev_page, page: page}

  process_date_events: ([date, events]) ->
    {date: date, events: Ember.A(@create(event)) for event in events}

Twitarr.Event = Twitarr.EventMeta.extend
  description: null
  end_time: null

  delete: ->
    $.ajax("/event/#{@get('id')}", method: 'DELETE', async: false, dataType: 'json', cache: false).done (data) =>
      if(!data)
        alert("Successfully deleted")
        true
      else
        alert data.status
        false

Twitarr.Event.reopenClass
  get: (event_id) ->
    $.getJSON("/event/#{event_id}").then (data) =>
      @create(data)

  get_edit: (event_id) ->
    $.getJSON("/event/#{event_id}").then (data) =>
      g = @create(data)
      # Format the time to a usable format for the front-end.
      g.start_time = moment.utc(g.start_time).local().format().slice(0, -6)
      g.end_time = moment.utc(g.end_time).local().format().slice(0, -6) if g.end_time
      g

  edit: (event_id, description, location, start_time, end_time) ->
    $.ajax("/event/#{event_id}",
      method: 'PUT',
      data: {description: description, location: location, start_time: start_time, end_time: end_time}).then (data) =>
    data.event = @create(data.event) if data.event?
    data

  new_event: (title, description, location, start_time, end_time) ->
    $.post('/event',
      title: title,
      description: description,
      location: location,
      start_time: start_time,
      end_time: end_time).then (data) =>
    data.event = @create(data.event) if data.event?
    data
