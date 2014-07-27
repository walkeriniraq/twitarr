Twitarr.StreamPost = Ember.Object.extend
  id: null
  author: null
  text: null
  timestamp: null

Twitarr.StreamPost.reopenClass
  page: (page) ->
    $.getJSON("stream/#{page}").then (data) =>
      Ember.A().pushObject(@create(post)) for post in data.stream_posts

  new_post: (text) ->
    $.post 'stream', text: text

