@Twitarr.controller 'AlertBarCtrl', ($scope, $http, $route, UserService) ->
  $scope.displayed_alerts = []
  displayed = false

  display_alerts = (alerts) ->
    if displayed
      window.setTimeout(display_alerts, 100, alerts)
    else
      $scope.displayed_alerts = alerts
      $("#alert-bar").show()
      $("#alert-bar").toggleClass "on"
      displayed = true
      # There were times where alerts displayed right after each other failed to change the data in the template
      if $scope.$root.$$phase != '$apply' and $scope.$root.$$phase != '$digest' 
        $scope.$apply();
      window.setTimeout($scope.hide_alerts, 5000)

  $scope.hide_alerts = (stage) ->
    if stage == undefined or stage == 0
      $("#alert-bar").toggleClass("on")
      window.setTimeout($scope.hide_alerts,500,1)
    if stage == 1
      $scope.display_alerts = []
      $("#alert-bar").hide()    
      displayed = false
      if $scope.$root.$$phase != '$apply' and $scope.$root.$$phase != '$digest' 
        $scope.$apply();

  $scope.$on('alert', (event, args) ->
    display_alerts args.messages
  )
  #$scope.$broadcast('alert', {messages: ["Alert 1", "Alert 2"]})