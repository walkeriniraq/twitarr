Twitarr.EventMeta = Ember.Object.extend
  events: null

Twitarr.EventMeta.reopenClass
  page: (page) ->
    # Yeah. I know how gross this is. Forgive me.
    # I blame ember for this.
    page = parseInt(page)
    current_events = {}
    past_events = {}
    upcoming_events = {}
    current_a = []
    past_a = []
    upcoming_a = []
    past_page = undefined
    next_page = undefined
    $.when(
      $.getJSON("event/page/#{page}").then (data) =>
        past_page = data.past_page
        next_page = data.next_page
        for e in data.events
          m = moment(e.start_time)
          d = "#{m.date()}"

          # Only list current events.
          current_events[d] = {} if current_events[d] == undefined
          current_events[d]["date"] = m.format('MMMM Do') if current_events[d]["date"] == undefined
          current_events[d]["events"] = [] if current_events[d]["events"] == undefined
          current_events[d]["events"].push(Twitarr.Event.create(e))
        for key of current_events
          current_a.push Twitarr.EventDateMeta.create(current_events[key])

      if page == 0
        $.getJSON("event/recent").then (data) =>
          for e in data.events
            m = moment(e.start_time)
            d = "#{m.date()}"

            past_events[d] = {} if past_events[d] == undefined
            past_events[d]["date"] = m.format('MMMM Do') if past_events[d]["date"] == undefined
            past_events[d]["events"] = [] if past_events[d]["events"] == undefined
            past_events[d]["events"].push(Twitarr.Event.create(e))
          for key of past_events
            past_a.push Twitarr.EventDateMeta.create(past_events[key])

        $.getJSON("event/upcoming").then (data) =>
          for e in data.events
            m = moment(e.start_time)
            d = "#{m.date()}"

            upcoming_events[d] = {} if upcoming_events[d] == undefined
            upcoming_events[d]["date"] = m.format('MMMM Do') if upcoming_events[d]["date"] == undefined
            upcoming_events[d]["events"] = [] if upcoming_events[d]["events"] == undefined
            upcoming_events[d]["events"].push(Twitarr.Event.create(e))
          for key of upcoming_events
            upcoming_a.push Twitarr.EventDateMeta.create(upcoming_events[key])
    ).then ->
      { events: current_a, past_events: past_a, upcoming_events: upcoming_a, page: page, past_page: past_page, next_page: next_page }

  past_page: (page) ->
    page = parseInt(page)
    events = {}
    a = []
    past_page = undefined
    next_page = undefined
    $.when(
      $.getJSON("event/recent/#{page}").then (data) =>
        for e in data.events
          m = moment(e.start_time)
          d = "#{m.date()}"

          events[d] = {} if events[d] == undefined
          events[d]["date"] = m.format('MMMM Do') if events[d]["date"] == undefined
          events[d]["events"] = [] if events[d]["events"] == undefined
          events[d]["events"].push(Twitarr.Event.create(e))
        for key of events
          a.push Twitarr.EventDateMeta.create(events[key])
    ).then ->
      { events: a, page: page, past_page: past_page, next_page: next_page }

Twitarr.EventDateMeta = Ember.Object.extend
  date: ""
  events: []

Twitarr.Event = Ember.Object.extend
  author: null
  display_name: null
  title: null
  description: null
  location: null
  start_time: null
  end_time: null
  official: null
  max_signups: null
  signups: []
  favorites: []

  signup: ->
    $.post("/api/v2/event/#{@get('id')}/signup").then (data) =>
      if(!data.error or !data.errors)
        @set('signups', data.event.signups)
      else
        alert data.error || data.errors.join("\n")

  unsignup: ->
    $.ajax("/api/v2/event/#{@get('id')}/signup", method: 'DELETE', async: false, dataType: 'json', cache: false).done (data) =>
      if(!data.error or !data.errors)
        @set('signups', data.event.signups)
      else
        alert data.error || data.errors.join("\n")

  delete: ->
    $.ajax("/api/v2/event/#{@get('id')}", method: 'DELETE', async: false, dataType: 'json', cache: false).done (data) =>
      if(!data)
        alert("Successfully deleted")
        true
      else
        alert data.status
        false

  favourite: ->
    $.post("/api/v2/event/#{@get('id')}/favorite").then (data) =>
      if(!data.error or !data.errors)
        @set('favorites', data.event.favorites)
      else
        alert data.error || data.errors.join("\n")

  unfavourite: ->
    $.ajax("/api/v2/event/#{@get('id')}/favorite", method: 'DELETE', async: false, dataType: 'json', cache: false).done (data) =>
      if(!data.error or !data.errors)
        @set('favorites', data.event.favorites)
      else
        alert data.error || data.errors.join("\n")

Twitarr.Event.reopenClass
  get: (event_id) ->
    $.getJSON("/api/v2/event/#{event_id}").then (data) =>
      Twitarr.Event.create(data)

  edit: (event_id, description, location, start_time, end_time, max_signups) ->
    $.post("/api/v2/event/#{event_id}", method: 'PUT', description: description, location: location, start_time: start_time, end_time: end_time, max_signups: max_signups).then (data) =>
      data.event = Twitarr.Event.create(data.event) if data.event?
      data

  new_event: (title, description, location, start_time, end_time, max_signups) ->
    $.post('/api/v2/event/', title: title, description: description, location: location, start_time: start_time, end_time: end_time, max_signups: max_signups).then (data) =>
      data.event = Twitarr.Event.create(data.event) if data.event?
      data
