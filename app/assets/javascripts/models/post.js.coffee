Twitarr.Post = Twitarr.BasePost.extend()

Twitarr.Post.reopenClass

  create: (params) ->
    post = @_super(params)
    post.set('photos', (Twitarr.Photo.create(photo) for photo in params.data.photos)) if params.data && params.data.photos
    post

  new: (text, photos) ->
    filenames = (photo.file for photo in photos)
    $.post("posts/submit", { message: text, photos: filenames }).done (data) ->
      unless data.status is 'ok'
        alert data.status

  search: (tag, info) ->
    url = "posts/search?term=#{encodeURIComponent tag}"
    if info
      url += "&dir=#{encodeURIComponent info.direction}&time=#{encodeURIComponent info.time}"
    @get_list(url)

  feed: (info) ->
    url = "posts/feed"
    if info
      url += "?dir=#{info.direction}&time=#{info.time}"
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

  delete: (id) ->
    Twitarr.BasePost.delete('posts', id)
