#= require_tree ./modules
#= require_self
#= require_tree ./controllers
# require_tree ./helpers
# require_tree ./routes
# require_tree ./templates
# require_tree ./views

@Twitarr = angular.module('twitarr', ['ngRoute', 'ngSanitize', 'angularLocalStorage', 'twitarr.User'])

pretty_username = (username, display_name) ->
  if !!display_name && username isnt display_name
    "<span title='@#{username}'>#{display_name}</span>"
  else
    '@' + username

display_name_plus_username = (username, display_name) ->
  if !!display_name && username isnt display_name
    "#{display_name} (@#{username})"
  else
    '@' + username