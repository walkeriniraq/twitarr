class User
  constructor: (user = null) ->
    if user is null
      @username = ko.observable null
      @status = ko.observable 'inactive'
      @email = ko.observable null
      @empty_password = ko.observable true
      @is_admin = ko.observable false
    else
      @username = ko.observable user.username
      @status = ko.observable user.status
      @email = ko.observable user.email
      @empty_password = ko.observable user.empty_password
      @is_admin = ko.observable user.is_admin

    @not_active = ko.computed =>
      @status() isnt 'active'

  clone: =>
    new User @instance_data()

  instance_data: =>
    username: @username()
    status: @status()
    email: @email()
    is_admin: @is_admin()

class TwitarrAdmin
  constructor: ->
    @users = ko.observableArray()
    @user_edit = ko.observable null
    @page = ko.observable 'user_list'
    @on_user_list = ko.computed =>
      @page() is 'user_list'
    @on_user_add = ko.computed =>
      @page() is 'user_add'
    @on_user_edit = ko.computed =>
      @page() is 'user_edit'
    @on_user_reset_password = ko.computed =>
      @page() is 'user_reset_password'

    $(document).on 'click', '.user_edit', (event) =>
      user = @find_user $(event.target).data('name')
      @user_edit user.clone()
      @page 'user_edit'

    $(document).on 'click', '.reset_password', (event) =>
      user = @find_user $(event.target).data('name')
      @user_edit user.clone()
      @page 'user_reset_password'

    $(document).on 'click', '#user_add', =>
      @user_edit new User()
      @page 'user_add'

    $(document).on 'click', '.user_delete', (event) =>
      if confirm "Are you sure you want to delete?"
        user = @find_user $(event.target).data('name')
        $.post 'admin/delete_user', { username: user.username() }, (data) =>
          if data.status is 'ok'
            @users.remove user
          else
            alert data.status

    $(document).on 'click', '.user_activate', (event) =>
      $.post 'admin/activate', { username: $(event.target).data('name') }, (data) =>
        if data.status is 'ok'
          user = @find_user $(event.target).data('name')
          user.status 'active'
        else
          alert data.status

    $(document).on 'click', '#user_reset_password_save', =>
      password = $('#reset_password_input').val()
      $.post 'admin/reset_password', { username: @user_edit().username(), new_password: password }, (data) =>
        if data.status is 'ok'
          @page 'user_list'
        else
          alert data.status

    $(document).on 'click', '#user_edit_save', =>
      $.post 'admin/update_user', { data: @user_edit().instance_data() }, (data) =>
        if data.status is 'ok'
          user = @find_user @user_edit().username()
          idx = @users.indexOf user
          @users()[idx] = @user_edit()
          @users.valueHasMutated()
          @page 'user_list'
        else
          alert data.status

    $(document).on 'click', '#user_add_save', =>
      $.post 'admin/add_user', { data: @user_edit().instance_data() }, (data) =>
        if data.status is 'ok'
          @users.push @user_edit()
          @page 'user_list'
        else
          alert data.status

    $(document).on 'click', '.user_edit_cancel', => @page('user_list')

  find_user: (username) =>
    _(@users()).find (user) -> user.username() is username

  add_users: (list) =>
    @users.push new User(user) for user in list

window.twitarr_admin = new TwitarrAdmin()

$ ->
  ko.applyBindings window.twitarr_admin

  $.getJSON 'admin/users', (data) ->
    window.twitarr_admin.users.removeAll()
    window.twitarr_admin.add_users data.list
