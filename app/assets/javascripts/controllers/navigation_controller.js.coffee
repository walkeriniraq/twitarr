@Twitarr.controller 'NavCtrl', ['$scope','$http', 'UserService', ($scope, $http,UserService) ->
  $scope.user = UserService.get()
  $scope.display_name = ""
  $scope.alerts = false
  $scope.menu_toggle = ->
    $('#side-menu').animate { width: 'toggle' }, 100
    return

  $scope.show_login = ->
    $scope.menu_toggle()
    $('#login-modal-container').show()
    return

  $scope.hide_login = ->
    $('#login-modal-container').hide()
    return

  $scope.logout = (user) ->
    console.log 'Logging out'
    user.loggedIn = false
    UserService.reset user
    user = UserService.get()

  $scope.submit_login = (user) ->
    console.log 'Logging in.'
    loginPasswordElement = $('#loginPassword')
    loginUsernameElement = $('#loginUsername')
    if !user.username
      return
    loginPasswordElement.prop('disabled', true)
    loginUsernameElement.prop('disabled', true)
    loginUsernameElement.toggleClass("disabled")
    loginPasswordElement.toggleClass("disabled")
    user.username = user.username.toLowerCase()
    url = '/api/v2/user/auth'
    $http(
      method: 'GET'
      url: url
      params:
        username: user.username
        password: user.password
      cache: false
      timeout: 5000
      headers: Accept: 'application/json').success((data, status, headers, config) ->
      key = if data then data.key else undefined
      console.log 'Success: ' + key
      user.key = key
      user.loggedIn = true
      user.isAdmin = data.admin
      if user.username
        user.username = user.username.toLowerCase()
      url = '/api/v2/user/whoami'
      $http(
        method: 'GET'
        url: url
        params:
          key: user.key
        cache: false
        timeout: 50000
        headers: Accept: 'application/json').success((data, status, headers, config) ->
        data = data.user
        user.isAdmin = data.is_admin
        user.displayname = data.display_name
        console.log 'Saving user: ' + user.username
        console.log 'Admin? ' + user.isAdmin
        UserService.save user
        loginPasswordElement.prop('disabled', false)
        loginUsernameElement.prop('disabled', false)
        loginUsernameElement.toggleClass("disabled")
        loginPasswordElement.toggleClass("disabled")
        loginPasswordElement.text = ""
        $scope.hide_login()
        return)
      return
    ).error (data, status, headers, config) ->
      console.log 'Failure!'
      console.log 'URL:' + url
      console.log 'Status:' + status
      console.log 'Data:'
      console.log data
      console.log 'Headers:'
      console.log headers
      console.log 'Config:'
      console.log config
      loginPasswordElement.prop('disabled', false)
      loginUsernameElement.prop('disabled', false)
      loginUsernameElement.toggleClass("disabled")
      loginPasswordElement.toggleClass("disabled")
      return


]