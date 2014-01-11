Twitarr.Post = Twitarr.BasePost.extend()

Twitarr.Post.reopenClass

  create: (params) ->
    post = @_super(params)
    if params.data
      post.set('photos', (Twitarr.Photo.create(photo) for photo in params.data.photos)) if params.data.photos
      post.set('replies', (Twitarr.Reply.create(reply) for reply in params.data.replies)) if params.data.replies
    post

  new: (text, photos) ->
    filenames = (photo.file for photo in photos)
    $.post("posts/submit", { message: text, photos: filenames })

  search: (tag, info) ->
    url = "posts/search?term=#{encodeURIComponent tag}"
    if info
      url += "&dir=#{encodeURIComponent info.direction}&time=#{encodeURIComponent info.time}"
    @get_list(url)

  popular: (info) ->
    url = "posts/popular"
    if info
      url += "?dir=#{info.direction}&time=#{info.time}"
    @get_list(url)

  all: (info) ->
    url = "posts/all"
    if info
      url += "?dir=#{encodeURIComponent info.direction}&time=#{encodeURIComponent info.time}"
    @get_list(url)

  user: (username, info) ->
    url = "posts/list?username=#{encodeURIComponent username}"
    if info
      url += "&dir=#{encodeURIComponent info.direction}&time=#{encodeURIComponent info.time}"
    @get_list(url)

  favorite: (id) ->
    $.ajax(type: 'PUT', url: 'posts/favorite', data: { id: id }).done (data) ->
      unless data.status is 'ok'
        alert data.status

  reply: (text, id) ->
    $.post('posts/reply', { message: text, id: id }).done (data) ->
      if data.status is 'ok'
        console.log 'updated'
      else
        alert data.status

  delete: (id) ->
    Twitarr.BasePost.delete('posts', id)
