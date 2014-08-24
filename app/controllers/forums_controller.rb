class ForumsController < ApplicationController

  def index
    render_json forum_meta: Forum.all.sort_by { |x| x.last_post }.reverse.map { |x| x.decorate.to_meta_hash }
  end

  def show
    render_json forum: Forum.find(params[:id]).decorate.to_hash
  end

  def create
    forum = Forum.create_new_forum current_username, params[:subject], params[:text]
    if forum.valid?
      render_json forum_meta: forum.decorate.to_meta_hash
    else
      render_json errors: forum.errors.full_messages
    end
  end

  def new_post
    forum = Forum.find(params[:forum_id])
    post = forum.add_post current_username, params[:text]
    if post.valid?
      render_json forum_post: post.decorate.to_hash
    else
      render_json errors: post.errors.full_messages
    end
  end

end