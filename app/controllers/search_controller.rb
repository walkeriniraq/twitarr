class SearchController < ApplicationController

  def search
    search_text = params[:text].strip.downcase
    render_json status: 'no text' and return if search_text.blank?
    user_query = User.or({ username: /^#{search_text}/ }, { '$text' => { '$search' => "\"#{search_text}\"" } })
    seamail_query = Seamail.where(usernames: current_username).or({ usernames: /^#{search_text}/ }, { '$text' => { '$search' => "\"#{search_text}\"" } })
    tweet_query = StreamPost.where({ '$text' => { '$search' => "\"#{search_text}\"" } })
    forum_query = Forum.where({ '$text' => { '$search' => "\"#{search_text}\"" } })
    render_json status: 'ok', results: {
        users: user_query.limit(3).map { |x| x.decorate.gui_hash },
        more_users: user_query.count > 3,
        seamails: seamail_query.limit(3).map { |x| x.decorate.to_meta_hash },
        more_seamails: seamail_query.count > 3,
        tweets: tweet_query.limit(3).map { |x| x.decorate.to_hash },
        more_tweets: tweet_query.count > 3,
        forums: forum_query.limit(3).map { |x| x.decorate.to_meta_hash },
        more_forums: forum_query.count > 3
    }
  end

end
