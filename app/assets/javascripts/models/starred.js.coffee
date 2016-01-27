Twitarr.StarredMeta = Ember.Object.extend
  starred: []

Twitarr.StarredMeta.reopenClass
  get: ->
    $.getJSON("user/starred").then (data) =>
      {starred: Ember.A(Twitarr.Starred.create(user)) for user in data.users}

Twitarr.Starred = Ember.Object.extend
  username: null
  display_name: null
  comment: ""
  last_photo_updated: null

  save: ->
    $.post("user/profile/#{@get('username')}/personal_comment", { comment: @get('comment') })