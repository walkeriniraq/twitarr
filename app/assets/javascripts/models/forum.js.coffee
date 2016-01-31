Twitarr.ForumMeta = Ember.Object.extend
  id: null
  subject: null
  posts: null
  timestamp: null

Twitarr.ForumMeta.reopenClass
  list: ->
    $.getJSON('api/v2/forums').then (data) =>
      Ember.A(@create(meta)) for meta in data.forum_meta

  page: (page) ->
    $.getJSON("api/v2/forums?page=#{page}").then (data) =>
      { forums: Ember.A(@create(meta)) for meta in data.forum_meta, next_page: data.next_page, prev_page: data.prev_page }

Twitarr.Forum = Ember.Object.extend
  id: null
  subject: null
  posts: []
  timestamp: null

  objectize: (->
    @set('posts', Ember.A(Twitarr.ForumPost.create(post)) for post in @get('posts'))
  ).on('init')

Twitarr.Forum.reopenClass
  get: (id, page = 0) ->
    $.getJSON("api/v2/forums/thread/#{id}?page=#{page}").then (data) =>
      { forum: @create(data.forum), next_page: data.forum.next_page, prev_page: data.forum.prev_page }

  new_post: (forum_id, text, photos) ->
    $.post("api/v2/forums/thread/#{forum_id}", { text: text, photos: photos }).then (data) =>
      data.forum_post = Twitarr.ForumPost.create(data.forum_post) if data.forum_post?
      data

  new_forum: (subject, text, photos) ->
    $.ajax("api/v2/forums", method: 'PUT', data: { subject: subject, text: text, photos: photos }).then (data) =>
      data.forum_meta = Twitarr.ForumMeta.create(data.forum_meta) if data.forum_meta?
      data

Twitarr.ForumPost = Ember.Object.extend
  photos: []

  objectize: (->
    @set('photos', Ember.A(Twitarr.Photo.create(photo) for photo in @get('photos')))
  ).on('init')

  user_likes: (->
    @get('likes') && @get('likes')[0] == 'You'
  ).property('likes')

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
    $.getJSON("api/v2/forums/thread/#{@get('forum_id')}/like/#{@get('id')}").then (data) =>
      if(data.status == 'ok')
        @set('likes', data.likes)
      else
        alert data.status

  unlike: ->
    $.getJSON("api/v2/forums/thread/#{@get('forum_id')}/unlike/#{@get('id')}").then (data) =>
      if(data.status == 'ok')
        @set('likes', data.likes)
      else
        alert data.status