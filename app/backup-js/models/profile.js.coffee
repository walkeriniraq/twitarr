#Twitarr.Profile = Ember.Object.extend
#  display_name: null
#  security_question: null
#  security_answer: null
#
#Twitarr.Profile.reopenClass
#  get: ->
#    $.getJSON('user/profile').then (data) =>
#      @create(data)