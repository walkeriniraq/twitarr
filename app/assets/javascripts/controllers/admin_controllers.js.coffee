Twitarr.AdminUsersController = Twitarr.ArrayController.extend()

Twitarr.AdminUserPartialController = Twitarr.ObjectController.extend
  changed: false

  is_active: (->
    @get('status') is 'active'
  ).property('status')

  values_changed: (->
    @set('changed', true)
  ).observes('display_name', 'is_admin', 'status', 'email')

Twitarr.AdminAnnouncementsController = Twitarr.Controller.extend()

Twitarr.AdminUploadScheduleController = Twitarr.Controller.extend
  actions:
    file_uploaded: (data) ->
      alert data.status unless data.status is 'ok'
    start_upload: ->
      @get('controllers.application').send('start_upload')
    end_upload: ->
      @get('controllers.application').send('end_upload')

