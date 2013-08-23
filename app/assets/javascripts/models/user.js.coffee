Twitarr.User = Ember.Object.extend

  is_locked: (->
    @get('status') isnt 'active'
  ).property 'status'

Twitarr.User.reopenClass
  list: ->
    $.getJSON('admin/users').then (data) =>
      users = Ember.A()
      users.pushObject(@create(user)) for user in data.list
      { status: data.status, users: users }

