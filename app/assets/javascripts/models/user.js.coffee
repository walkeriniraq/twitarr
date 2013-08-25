Twitarr.User = Ember.Object.extend
  is_admin: false
  username: null
  status: null
  email: null
  empty_password: false

  is_locked: (->
    @get('status') isnt 'active'
  ).property 'status'

  save: ->
    $.ajax(type: 'POST', url: 'admin/update_user', data: @serialize()).done (data) ->
      unless data.status is 'ok'
        alert data.status

  create_new: ->
    $.ajax(type: 'PUT', url: 'admin/add_user', data: @serialize()).done (data) ->
      unless data.status is 'ok'
        alert data.status

  serialize: ->
    result = {}
    for key of $.extend(true, {}, this)
      # Skip these
      continue if key is "isInstance" or key is "isDestroyed" or key is "isDestroying" or key is "concatenatedProperties" or typeof this[key] is "function"
      result[key] = this[key]
    result

Twitarr.User.reopenClass
  list: ->
    $.getJSON('admin/users').then (data) =>
      users = Ember.A()
      users.pushObject(@create(user)) for user in data.list
      { status: data.status, users: users }

  find: (username) ->
    $.getJSON('admin/find_user', { username: username }).then (data) =>
      return data.status unless data.status is 'ok'
      user = @create(data.user)
      console.log user.get('is_admin')
      user
