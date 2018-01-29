class API::V2::ForumsController < ApplicationController
  skip_before_action :verify_authenticity_token

  POST_COUNT = 20
  before_filter :login_required, :only => [:create, :update_post, :like, :unlike]
  before_filter :fetch_forum, :except => [:index, :create, :show, :rc_forums, :rc_forum]

  def index
    page_size = (params[:limit] || 20).to_i
    page = (params[:page] || 0).to_i

    query = Forum.all.desc(:last_post_time).offset(page * page_size).limit(page_size)

    next_page = if Forum.count > (page + 1) * page_size
                  page + 1
                else
                  nil
                end
    prev_page = if page > 0
                  page - 1
                else
                  nil
                end
    render_json forum_meta: query.map { |x| x.decorate.to_meta_hash(current_user) }, next_page: next_page, prev_page: prev_page
  end

  def show
    limit = (params[:limit] || POST_COUNT).to_i
    start_loc = (params[:page] || 0).to_i

    query = Forum.find(params[:id]).decorate
    if current_user
      query = query.to_paginated_hash(start_loc, limit, current_user) if params.has_key?(:page)
      query = query.to_hash(current_user) if !params.has_key?(:page)
    else
      query = query.to_paginated_hash(start_loc, limit) if params.has_key?(:page)
      query = query.to_hash() if !params.has_key?(:page)
    end

    render_json forum: query
    current_user.update_forum_view(params[:id]) if logged_in?
  end

  def create
    forum = Forum.create_new_forum current_username, params[:subject], params[:text], params[:photos]
    if forum.valid?
      render_json forum_meta: forum.decorate.to_meta_hash
    else
      render_json errors: forum.errors.full_messages
    end
  end

  def new_post
    post = @forum.add_post current_username, params[:text], params[:photos]
    if post.valid?
      @forum.save
      render_json forum_post: post.decorate.to_hash(current_user, nil, request_options)
    else
      render_json errors: post.errors.full_messages
    end
  end

  def like
    post = @forum.posts.find(params[:post_id])
    post = post.add_to_set likes: current_username
    post.likes[post.likes.index(current_username)] = 'You'
    render status: :ok, json: {status: 'ok', likes: post.likes}
  end

  def unlike
    post = @forum.posts.find(params[:post_id])
    post = post.pull likes: current_username
    render status: :ok, json: {status: 'ok', likes: post.likes}
  end

  def rc_forums
    return unless logged_in!
    start_loc = params[:since]
    limit = params[:limit] || 0
    forums = Forum.unscoped.where(:updated_at.gte => start_loc).only(:id, :subject, :created_at, :deleted_at).limit(limit).order_by(created_at: :asc)
    render json: forums
  end

   def rc_forum
 	  return unless logged_in!
 		forum_id = params[:id]
 		start_loc = params[:since]
    limit = params[:limit] || 0
 	  posts = Forum.unscoped.where(:id => forum_id, :updated_at.gte => start_loc).only(:id, :posts).limit(limit)
    render json: posts
  end
    
  private
  def fetch_forum
    @forum = Forum.find(params[:id])
  end

  def login_required
    head :unauthorized unless logged_in? || valid_key?(params[:key])
  end
end
