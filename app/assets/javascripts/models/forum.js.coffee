Twitarr.ForumMeta = Ember.Object.extend
  id: null
  subject: null
  posts: 0
  timestamp: null

Twitarr.ForumMeta.reopenClass
  list: ->
    $.getJSON('forums').then (data) =>
      Ember.A().pushObject(@create(meta)) for meta in data.forum_meta

Twitarr.Forum = Ember.Object.extend
  id: null
  subject: null
  posts: []
  timestamp: null

  init: ->
    @set('posts', Ember.A().pushObject(Twitarr.ForumPost.create(post)) for post in @get('posts'))

Twitarr.Forum.reopenClass
  get: (id) ->
    $.getJSON("forums/#{id}").then (data) =>
      @create(data.forum)

  new_post: (forum_id, text) ->
    $.post('forums', { forum_id: forum_id, text: text })

Twitarr.ForumPost = Ember.Object.extend
  id: null
  author: null
  text: null
  timestamp: null
