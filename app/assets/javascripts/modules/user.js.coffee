angular.module('twitarr.User', [ 'angularLocalStorage' ]).factory 'UserService', ['$rootScope', 'storage', ($rootScope, storage) ->
    defaultValue = 
      'loggedIn': false
      'username': ''
      'password': ''
      'key'     : ''
      'isAdmin' : false
    $rootScope.user = storage.get('twitarr.user')
    if !$rootScope.user
      $rootScope.user = angular.copy(defaultValue)

    getUser = ->
      angular.copy $rootScope.user

    setUser = (user) ->
      oldUser = getUser()
      savedUser = angular.copy(user)
      savedUser.username = savedUser.username.toLowerCase()
      $rootScope.user = savedUser
      storage.set 'twitarr.user', savedUser
      $rootScope.$broadcast 'twitarr.user.updated', savedUser, oldUser
      return

    {
      'loggedIn': ->
        getUser().loggedIn
      'getUsername': ->
        user = getUser()
        if user.loggedIn and user.username
          user.username
        else
          undefined
      'matches': (username) ->
        if username
          username = username.toLowerCase()
        $rootScope.user.username == username
      'get': ->
        getUser()
      'save': (newUser) ->
        setUser newUser
        return
      'reset': ->
        user = getUser()
        user.loggedIn = false
        user.password = undefined
        user.isAdmin  = false
        setUser user
        getUser()
    }
]
