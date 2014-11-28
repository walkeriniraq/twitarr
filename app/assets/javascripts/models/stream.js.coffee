Twitarr.StreamPost = Ember.Object.extend
  id: null
  author: null
  text: null
  timestamp: null
  photo: null
  likes: []

  init: ->
    @set('timestamp', @get('timestamp') * 1000)

  pretty_timestamp: (->
    moment(@get('timestamp')).fromNow(true)
  ).property('timestamp')

  sm_photo_path: (->
    Twitarr.ApplicationController.sm_photo_path @get('photo')
  ).property('photo')

  likes_string: (->
    likes = @get('likes')
    if likes.length == 1
      if @get('user_likes')
        return 'You like this.'
      return "#{likes[0]} likes this."
    last = likes.pop()
    likes.join(', ') + " and #{last} like this."
  ).property('likes')

  user_likes: (->
    @get('likes') && @get('likes')[0] == 'You'
  ).property('likes')

  like: ->
    $.getJSON("tweet/like/#{@get('id')}").then (data) =>
      if(data.status == 'ok')
        @set('likes', data.likes)
      else
        alert data.status

  unlike: ->
    $.getJSON("tweet/unlike/#{@get('id')}").then (data) =>
      if(data.status == 'ok')
        @set('likes', data.likes)
      else
        alert data.status

Twitarr.StreamPost.reopenClass
  page: (page) ->
    $.getJSON("stream/#{page}").then (data) =>
      { posts: Ember.A(@create(post) for post in data.stream_posts), next_page: data.next_page }

  new_post: (text, photo) ->
    $.post('stream', text: text, photo: photo).then (data) =>
      data.stream_post = Twitarr.StreamPost.create(data.stream_post) if data.stream_post?
      data
