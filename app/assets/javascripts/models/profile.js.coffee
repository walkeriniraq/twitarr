Twitarr.Profile = Ember.Object.extend
  save: ->
    post_data = { display_name: @get('display_name'), email: @get('email'), room_number: @get('room_number'), "email_public?": @get('email_public?'), real_name: @get('real_name'), home_location: @get('home_location') }
    if @get('current_password') and @get('new_password') and @get('confirm_password')
      if @get('new_password') != @get('confirm_password')
        alert "Current password and confirm password do not match!"
        return
      post_data["current_password"] = @get('current_password')
      post_data["new_password"] = @get('new_password')

    $.post('user/save_profile', post_data)

Twitarr.Profile.reopenClass
  get: ->
    $.getJSON("api/v2/user/whoami").then (data) =>
      @create(data.user)
