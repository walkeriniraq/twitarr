class ForumsController < ApplicationController

  def index
    render_json forum_meta: Forum.all.order_by(last_post: :desc).map { |x| x.decorate.to_meta_hash }
  end

  def show
    render_json forum: Forum.find(params[:id]).decorate.to_hash
  end

  def create
    forum = Forum.new(author: current_username, subject: params[:subject])
    post = forum.forum_posts.new(author: current_username, text: params[:text], timestamp: Time.now)
    forum.last_post = post.timestamp
    post.save
    forum.save
    render_json forum_meta: forum.decorate.to_meta_hash
  end

  def new_post
    forum = Forum.find(params[:forum_id])
    post = forum.forum_posts.new(author: current_username, text: params[:text], timestamp: Time.now)
    forum.last_post = post.timestamp
    post.save
    forum.save
    render_json forum_post: post.decorate.to_hash
  end

end