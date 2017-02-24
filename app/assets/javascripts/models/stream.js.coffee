Twitarr.StreamPost = Ember.Object.extend
  author: null
  display_name: null
  text: null
  timestamp: null
  photo: null
  likes: []
  parent_chain: []

  objectize: (->
    photo = @get('photo')
    if photo
      @set 'photo', Twitarr.Photo.create(photo)
  ).on('init')

  user_likes: (->
    @get('likes') && @get('likes')[0] == 'You'
  ).property('likes')

  parent_id: (->
    _.first(@get('parent_chain')) or @get('id')
  ).property('parent_chain', 'id')

  likes_string: (->
    likes = @get('likes')
    return '' unless likes and likes.length > 0
    if likes.length == 1
      if likes[0] == 'You'
        return 'You like this.'
      if likes[0].indexOf('seamonkeys') > -1
        return "#{likes[0]} like this."
      else
        return "#{likes[0]} likes this."
    last = likes.pop()
    likes.join(', ') + " and #{last} like this."
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

  delete: ->
    $.getJSON("tweet/destroy/#{@get('id')}").then (data) =>
      if(data.status == 'ok')
        for child in @get('children')
          child.parent_chain = []
        alert("Successfully deleted")
      else
        alert data.status

Twitarr.StreamPost.reopenClass
  page: (page) ->
    $.getJSON("stream/#{page}").then (data) =>
      { posts: Ember.A(@create(post) for post in data.stream_posts), has_next_page: data.has_next_page, next_page: data.next_page }

  star_page: (page) ->
    $.getJSON("stream/star/#{page}").then (data) =>
      { posts: Ember.A(@create(post) for post in data.stream_posts), next_page: data.next_page, prev_page: data.prev_page }

  view: (post_id) ->
    $.getJSON("/api/v2/stream/#{post_id}").then (data) =>
      @create(data)

  get: (post_id) ->
    $.getJSON("tweet/#{post_id}").then (data) =>
      data.post.photo = Twitarr.Photo.create(data.post.photo) if data.post and data.post.photo
      data

  edit: (post_id, text, photo) ->
    $.post("tweet/edit/#{post_id}", text: text, photo: photo).then (data) =>
      data.stream_post = Twitarr.StreamPost.create(data.stream_post) if data.stream_post?
      data

  new_post: (text, photo) ->
    $.post('stream', text: text, photo: photo).then (data) =>
      data.stream_post = Twitarr.StreamPost.create(data.stream_post) if data.stream_post?
      data

  reply: (id, text, photo) ->
    $.post('stream', text: text, photo: photo, parent: id).then (data) =>
      data.stream_post = Twitarr.StreamPost.create(data.stream_post) if data.stream_post?
      data
