Twitarr.EventMeta = Ember.Object.extend
  events: null

Twitarr.EventMeta.reopenClass
  page: (page) ->
    $.getJSON("event/page/#{page}").then (data) =>
      h = {}
      a = []
      # Yeah. I know how gross this is. Forgive me.
      # I blame ember for this.
      for e in data.events
        m = moment(e.start_time)
        d = "#{m.date()}"
        
        h[d] = {} if h[d] == undefined
        h[d]["date"] = m.format('MMMM Do') if h[d]["date"] == undefined
        h[d]["events"] = [] if h[d]["events"] == undefined
        h[d]["events"].push(Twitarr.Event.create(e))
        
      for key of h
        a.push Twitarr.EventDateMeta.create(h[key])
      { events: a }

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
