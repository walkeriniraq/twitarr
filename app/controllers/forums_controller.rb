class ForumsController < ApplicationController

  def index
    render_json forum_meta: Forum.all.order_by(last_post: :desc).map { |x| x.decorate.to_meta_hash }
  end

  def show
    render_json forum: Forum.find(params[:id]).decorate.to_hash
  end

  def create
    render_json forum_post: Forum.find(params[:forum_id]).forum_posts.create(author: current_username, text: params[:text], timestamp: Time.now).decorate.to_hash
  end

end