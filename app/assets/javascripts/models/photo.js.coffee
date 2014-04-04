Twitarr.Photo = Ember.Object.extend
  thumb: null
  medium: null
  full: null
  file: null

Twitarr.Photo.reopenClass
  create: (filename) ->
    photo = new Twitarr.Photo
    photo.file = filename
    photo.thumb = "img/photos/sm_#{filename}"
    photo.full = "img/photos/#{filename}"
    photo.medium = "img/photos/md_#{filename}"
    photo

delete_photo: (full, thumb, medium) ->
    $.post("posts/delete_upload", { full: full, thumb: thumb, medium: medium } )