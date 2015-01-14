Twitarr.SeamailMeta = Ember.Object.extend
  id: null
  users: []
  messages: 0
  subject: null
  timestamp: null

Twitarr.SeamailMeta.reopenClass
  list: ->
    $.getJSON('seamail').then (data) =>
      Ember.A(@create(meta)) for meta in data.seamail_meta

Twitarr.Seamail = Ember.Object.extend
  id: null
  messages: []
  subject: null
  timestamp: null

  objectize: (->
    @set('messages', Ember.A(Twitarr.SeamailMessage.create(message)) for message in @get('messages'))
  ).on('init')

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
