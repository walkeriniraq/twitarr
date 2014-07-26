Twitarr.ForumTopic = Ember.Object.extend
  id: null
  subject: null
  posts: 0
  timestamp: null

Twitarr.ForumTopic.reopenClass
  list: ->
    $.getJSON('forum_topics').then (data) =>
      topics = Ember.A()
      topics.pushObject(@create(topic)) for topic in data.forum_topics
