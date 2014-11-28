class StreamController < ApplicationController

  def page
    posts = StreamPost.at_or_before(params[:page]).limit(20).order_by(timestamp: :desc).map { |x| x }
    next_page = posts.last.nil? ? 0 : (posts.last.timestamp.to_f * 1000).to_i - 1
    next_page = 0 if StreamPost.at_or_before(next_page).count < 1
    render_json stream_posts: posts.map { |x| x.decorate.to_hash(current_username) }, next_page: next_page
  end

  def create
    return unless logged_in!
    post = StreamPost.create(text: params[:text], author: current_username, timestamp: Time.now, photo: params[:photo])
    if post.valid?
      render_json stream_post: post.decorate.to_hash
    else
      render_json errors: post.errors.full_messages
    end
  end

  def like
    return unless logged_in!
    post = StreamPost.find(params[:id])
    post = post.add_like current_username
    render_json status: 'ok', likes: post.decorate.some_likes(current_username)
  end

  def unlike
    return unless logged_in!
    post = StreamPost.find(params[:id])
    post = post.remove_like current_username
    render_json status: 'ok', likes: post.decorate.some_likes(current_username)
  end

end