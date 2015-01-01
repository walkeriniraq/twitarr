class AlertsController < ApplicationController

  before_filter :login_required

  def login_required
    head :unauthorized unless logged_in?
  end

  def index
    tweet_mentions = StreamPost.view_mentions(query: current_username,
                                              after:current_user.last_viewed_alerts,
                                              mentions_only: true).map {|p| p.decorate.to_hash }
    forum_mentions = []
    announcements = []
    unread_seamail = current_user.seamails(unread: true).map{|m| m.decorate.to_meta_hash }

    current_user.reset_last_viewed_alerts
    current_user.save!
    render_json tweet_mentions: tweet_mentions, forum_mentions: forum_mentions,
                announcements: announcements, unread_seamail: unread_seamail
  end

  def check
    render_json status: 'ok', user: current_user.decorate.alerts_meta
  end
end
