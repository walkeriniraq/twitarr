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
