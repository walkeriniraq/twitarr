class SearchController < ApplicationController

  GENERIC_SEARCH_MAX = 3
  DETAILED_SEARCH_MAX = 50

  def search
    search_text = params[:text].strip.downcase
    render_json status: 'no text' and return if search_text.blank?
    params[:query] = params.delete :text

    # user_query = User.or({ username: /^#{search_text}/ }, { '$text' => { '$search' => "\"#{search_text}\"" } })
    # seamail_query = Seamail.where(usernames: current_username).or({ usernames: /^#{search_text}/ }, { '$text' => { '$search' => "\"#{search_text}\"" } })
    # tweet_query = StreamPost.or({ author: /^#{search_text}/ }, { '$text' => { '$search' => "\"#{search_text}\"" } })
    # forum_query = Forum.where({ '$text' => { '$search' => "\"#{search_text}\"" } })

    search_op = StreamPost.build_search_object(params)
    tweet_query = StreamPost.search(params).desc(:timestamp)
    forum_query = Forum.search(params)
    user_query = User.search(params)
    seamail_query = Seamail.search(params).desc(:last_update)

    render_json status: 'ok',
                text: params[:query],
                users: user_query.limit(GENERIC_SEARCH_MAX).map { |x| x.decorate.gui_hash },
                more_users: user_query.count > GENERIC_SEARCH_MAX,
                seamails: seamail_query.limit(GENERIC_SEARCH_MAX).map { |x| x.decorate.to_meta_hash },
                more_seamails: seamail_query.count > GENERIC_SEARCH_MAX,
                tweets: tweet_query.limit(GENERIC_SEARCH_MAX).map { |x| x.decorate.to_hash(current_username) },
                more_tweets: tweet_query.count > GENERIC_SEARCH_MAX,
                forums: forum_query.limit(GENERIC_SEARCH_MAX).map { |x| x.decorate.to_meta_hash },
                more_forums: forum_query.count > GENERIC_SEARCH_MAX,
                query: search_op
  end

  def search_users
    search_text = params[:text].strip.downcase
    render_json status: 'no text' and return if search_text.blank?
    params[:query] = params.delete :text
    user_query = User.search(params)
    render_json status: 'ok',
                text: params[:query],
                users: user_query.limit(DETAILED_SEARCH_MAX).map { |x| x.decorate.gui_hash },
                more_users: user_query.count > DETAILED_SEARCH_MAX
  end

  def search_tweets
    search_text = params[:text].strip.downcase
    render_json status: 'no text' and return if search_text.blank?
    params[:query] = params.delete :text
    tweet_query = StreamPost.search(params).desc(:timestamp)
    render_json status: 'ok',
                text: params[:query],
                tweets: tweet_query.limit(DETAILED_SEARCH_MAX).map { |x| x.decorate.to_hash(current_username) },
                more_tweets: tweet_query.count > DETAILED_SEARCH_MAX
  end

  def search_forums
    search_text = params[:text].strip.downcase
    render_json status: 'no text' and return if search_text.blank?
    params[:query] = params.delete :text
    forum_query = Forum.search(params)
    render_json status: 'ok',
                text: params[:query],
                forums: forum_query.limit(DETAILED_SEARCH_MAX).map { |x| x.decorate.to_meta_hash },
                more_forums: forum_query.count > DETAILED_SEARCH_MAX
  end

end
