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
    $.post('forum_posts', { forum_id: forum_id, text: text })