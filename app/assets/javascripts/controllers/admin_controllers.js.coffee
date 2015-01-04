Twitarr.AdminUsersController = Twitarr.ArrayController.extend
  actions: []

Twitarr.AdminUserPartialController = Twitarr.ObjectController.extend
  changed: false

  is_active: (->
    @get('status') is 'active'
  ).property('status')

  values_changed: (->
    @set('changed', true)
  ).observes('display_name', 'is_admin', 'status', 'email')
