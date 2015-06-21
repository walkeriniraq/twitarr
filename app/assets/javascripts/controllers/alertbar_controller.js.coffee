@Twitarr.controller 'AlertBarCtrl', ($rootScope, $scope, $http, $window, UserService) ->
  $scope.displayed_alerts = []
  $scope.link = undefined
  displayed = false

  display_alerts = (alerts, link) ->
    if displayed
      window.setTimeout(display_alerts, 100, alerts)
    else
      $scope.link = link
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
      $scope.link = undefined
      $scope.display_alerts = []
      $("#alert-bar").hide()    
      displayed = false
      if $scope.$root.$$phase != '$apply' and $scope.$root.$$phase != '$digest' 
        $scope.$apply();

  $scope.handle_click = () ->
    if $scope.link != undefined
      $window.location.assign($scope.link);
      $scope.hide_alerts()
    else
      $scope.hide_alerts()

  $rootScope.$on('alert', (event, args) ->
    display_alerts args.messages, args.link
  )
  #$scope.$emit('alert', {messages: ["Alert 1", "Alert 2"], link: '#/help'})