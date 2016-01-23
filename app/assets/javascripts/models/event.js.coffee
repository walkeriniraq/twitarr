Twitarr.EventMeta = Ember.Object.extend
  events: null
  next_page: null

Twitarr.EventMeta.reopenClass
  page: (page) ->
    $.getJSON("event/page/#{page}").then (data) =>
      { events: Ember.A(@create(meta)) for meta in data.events }

Twitarr.Event = Ember.Object.extend
  author: null
  display_name: null
  title: null
  description: null
  location: null
  start_time: null
  end_time: null
  official: null
  signups: null
  editable: false

  user_signups: (->
  	@get('signups') && @get('signups')[0] == 'You'
  ).property('signups')

  signups_string: (->
    signups = @get('signups')
    return '' unless signups and signups.length > 0
    if signups.length == 1
      if signups[0] == 'You'
        return 'You have signed up for this.'
      if signups[0].indexOf('seamonkeys') > -1
        return "#{signups[0]} have signed up for this."
      else
        return "#{signups[0]} have signed up for this."
    last = signups.pop()
    signups.join(', ') + " and #{last} like this."
  ).property('signups')

  has_signups: (->
    return @get('max_signups') > 0
  ).property('max_signups')

  signup: ->
    $.getJSON("event/signup/#{@get('id')}").then (data) =>
      if(data.status == 'ok')
        @set('signups', data.signups)
      else
        alert data.status

  unsignup: ->
    $.getJSON("event/unsignup/#{@get('id')}").then (data) =>
      if(data.status == 'ok')
        @set('signups', data.signups)
      else
        alert data.status

  delete: ->
    $.getJSON("event/destroy/#{@get('id')}").then (data) =>
      if(data.status == 'ok')
        alert("Successfully deleted")
        @transitionToRoute 'event.index'
      else
        alert data.status

Twitarr.Event.reopenClass
  get: (event_id) ->
    $.getJSON("event/#{event_id}").then (data) =>
      data.event

  edit: (event_id, title, description, location, start_time, end_time, max_signups) ->
    $.post("event/edit/#{event_id}", title: title, description: description, location: location, start_time: start_time, end_time: end_time, max_signups: max_signups).then (data) =>
      data.event = Twitarr.Event.create(data.event) if data.event?
      data

  new_event: (title, description, location, start_time, end_time, max_signups) ->
    $.post('event', title: title, description: description, location: location, start_time: start_time, end_time: end_time, max_signups: max_signups).then (data) =>
      data.event = Twitarr.Event.create(data.event) if data.event?
      data
