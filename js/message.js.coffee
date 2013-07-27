Twitarr.Message = Ember.Object.extend
  process_message: (->
    msg = ''
    msg += @process_part(part) for part in @get('message').split /([@#]\w+)/
    msg
  ).property 'message'

  process_part: (part) ->
    switch part[0]
      when '@'
        "<a href='#/posts/#{part.substring 1}'>#{part}</a>"
      when '#'
        "<a href='#/search/#{part.substring 1}'>#{part}</a>"
      else part

Twitarr.Message.reopenClass
  list: (type) ->
    @get_list "#{type}/list"

  post: (type, text) ->
    $.post("#{type}/submit", { message: text }).done (data) ->
      unless data.status is 'ok'
        alert data.status

  delete: (type, id) ->
    $.post("#{type}/delete", { id: id }).done (data) ->
      unless data.status is 'ok'
        alert data.status

  get_list: (url) ->
    $.getJSON(url).then (data) =>
      links = Ember.A()
      links.pushObject(Twitarr.Message.create(post)) for post in data.list
      links

  list_for_user: (username) ->
    @get_list("posts/list?username=#{encodeURIComponent username}").then (data) ->
      { account: username, posts: data }

  list_for_tag: (tag) ->
    @get_list("posts/search?term=#{encodeURIComponent tag}").then (data) ->
      { term: tag, posts: data }
