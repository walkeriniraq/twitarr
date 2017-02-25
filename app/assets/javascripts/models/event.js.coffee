Twitarr.EventMeta = Ember.Object.extend
  id: null
  author: null
  author_display_name: null
  title: null
  location: null
  start_time: null
  end_time: null
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
  mine: (date = new Date().toISOString().split('T')[0]) ->
    $.getJSON("/event/mine/#{date}").then (data) =>
      {events: Ember.A(@create(event)) for event in data.events, today: data.today, prev_day: data.prev_day, next_day: data.next_day }

  all: (date = new Date().toISOString().split('T')[0]) ->
    $.getJSON("/event/all/#{date}").then (data) =>
      {events: Ember.A(@create(event)) for event in data.events, today: data.today, prev_day: data.prev_day, next_day: data.next_day }

Twitarr.Event = Twitarr.EventMeta.extend
  description: null

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
