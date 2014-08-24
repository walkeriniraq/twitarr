Twitarr.SeamailMeta = Ember.Object.extend
  id: null
  users: []
  messages: 0
  subject: null
  timestamp: null

  users_display: (->
    @get('users').join(', ')
  ).property('users')

  pretty_timestamp: (->
    moment(@get('timestamp')).fromNow(true)
  ).property('timestamp')

Twitarr.SeamailMeta.reopenClass
  list: ->
    $.getJSON('seamail').then (data) =>
      Ember.A().pushObject(@create(meta)) for meta in data.seamail_meta

Twitarr.Seamail = Ember.Object.extend
  id: null
  users: []
  messages: []
  subject: null
  timestamp: null

  users_display: (->
    @get('users').join(', ')
  ).property('users')

  init: ->
    @set('messages', Ember.A().pushObject(Twitarr.SeamailMessage.create(message)) for message in @get('messages'))

Twitarr.Seamail.reopenClass
  get: (id) ->
    $.getJSON("seamail/#{id}").then (data) =>
      @create(data.seamail)

  new_message: (seamail_id, text) ->
    $.post('seamail/new_message', { seamail_id: seamail_id, text: text }).then (data) =>
      data.seamail_message = Twitarr.SeamailMessage.create(data.seamail_message) if data.seamail_message?
      data

  new_seamail: (users, subject, text) ->
    $.post('seamail', { users: users, subject: subject, text: text }).then (data) =>
      data.seamail = Twitarr.SeamailMeta.create(data.seamail_meta) if data.seamail_meta?
      data

Twitarr.SeamailMessage = Ember.Object.extend
  id: null
  author: null
  text: null
  timestamp: null

  pretty_timestamp: (->
    moment(@get('timestamp')).fromNow(true)
  ).property('timestamp')
