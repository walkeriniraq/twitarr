Twitarr.Profile = Ember.Object.extend
  save: ->
    $.post('user/save_profile', { display_name: @get('display_name'), email: @get('email') }).then (data) =>
      if (data.status isnt 'ok')
        alert data.status


Twitarr.Profile.reopenClass
  get: ->
    $.getJSON("api/v2/user/whoami").then (data) =>
      @create(data.user)
