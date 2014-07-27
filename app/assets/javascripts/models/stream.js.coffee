Twitarr.StreamPost = Ember.Object.extend
  id: null
  author: null
  text: null
  timestamp: null

Twitarr.StreamPost.reopenClass
  page: (page) ->
    $.getJSON("stream/#{page}").then (data) =>
      list = Ember.A()
      list.pushObject(@create(post)) for post in data.stream_posts
      { posts: list, next_page: data.next_page }

  new_post: (text) ->
    $.post 'stream', text: text

