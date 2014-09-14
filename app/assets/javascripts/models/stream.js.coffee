Twitarr.StreamPost = Ember.Object.extend
  id: null
  author: null
  text: null
  timestamp: null
  photo: null

  pretty_timestamp: (->
    moment(@get('timestamp')).fromNow(true)
  ).property('timestamp')

  sm_photo_path: (->
    Twitarr.ApplicationController.sm_photo_path @get('photo')
  ).property('photo')


Twitarr.StreamPost.reopenClass
  page: (page) ->
    $.getJSON("stream/#{page}").then (data) =>
      { posts: Ember.A(@create(post) for post in data.stream_posts), next_page: data.next_page }

  new_post: (text, photo) ->
    $.post('stream', text: text, photo: photo).then (data) =>
      data.stream_post = Twitarr.StreamPost.create(data.stream_post) if data.stream_post?
      data
