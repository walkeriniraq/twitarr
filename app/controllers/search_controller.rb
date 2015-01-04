class SearchController < ApplicationController

  GENERIC_SEARCH_MAX = 3
  DETAILED_SEARCH_MAX = 50

  def search
    search_text = params[:text].strip.downcase
    render_json status: 'no text' and return if search_text.blank?
    params[:limit] = GENERIC_SEARCH_MAX unless params[:limit]
    params[:current_username] = current_username

    tweet_query = StreamPost.search(params)
    forum_query = Forum.search(params)
    user_query = User.search(params)
    seamail_query = Seamail.search(params)

    render_json status: 'ok',
                users: user_query.map { |x| x.decorate.gui_hash },
                more_users: user_query.has_more?,
                seamails: seamail_query.map { |x| x.decorate.to_meta_hash },
                more_seamails: seamail_query.has_more?,
                tweets: tweet_query.map { |x| x.decorate.to_hash(current_username) },
                more_tweets: tweet_query.has_more?,
                forums: forum_query.map { |x| x.decorate.to_meta_hash },
                more_forums: forum_query.has_more?
  end

  def search_users
    search_text = params[:text].strip.downcase
    render_json status: 'no text' and return if search_text.blank?
    params[:limit] = DETAILED_SEARCH_MAX unless params[:limit]
    user_query = User.search(params)
    render_json status: 'ok',
                text: search_text,
                users: user_query.map { |x| x.decorate.gui_hash },
                more_users: user_query.has_more?
  end

  def search_tweets
    search_text = params[:text].strip.downcase
    render_json status: 'no text' and return if search_text.blank?
    params[:limit] = DETAILED_SEARCH_MAX unless params[:limit]
    tweet_query = StreamPost.search(params)
    render_json status: 'ok',
                text: search_text,
                tweets: tweet_query.map { |x| x.decorate.to_hash(current_username) },
                more_tweets: tweet_query.has_more?
  end

  def search_forums
    search_text = params[:text].strip.downcase
    render_json status: 'no text' and return if search_text.blank?
    params[:limit] = DETAILED_SEARCH_MAX unless params[:limit]
    forum_query = Forum.search(params)
    render_json status: 'ok',
                text: search_text,
                forums: forum_query.map { |x| x.decorate.to_meta_hash },
                more_forums: forum_query.has_more?
  end

end
