Twitarr.SeamailMeta = Ember.Object.extend
  id: null
  users: []
  messages: 0
  timestamp: null

  users_display: (->
    @get('users').join(', ')
  ).property('users')

Twitarr.SeamailMeta.reopenClass
  list: ->
    $.getJSON('seamail').then (data) =>
      Ember.A().pushObject(@create(meta)) for meta in data.seamail_meta

Twitarr.Seamail = Ember.Object.extend
  id: null
  users: []
  messages: []
  timestamp: null

  init: ->
    @set('messages', Ember.A().pushObject(Twitarr.SeamailMessage.create(message)) for message in @get('messages'))

Twitarr.Seamail.reopenClass
  get: (id) ->
    $.getJSON("seamail/#{id}").then (data) =>
      @create(data.seamail)

  new_message: (seamail_id, text) ->
    $.post('seamail', { seamail_id: seamail_id, text: text })

Twitarr.SeamailMessage = Ember.Object.extend
  id: null
  author: null
  text: null
  timestamp: null
