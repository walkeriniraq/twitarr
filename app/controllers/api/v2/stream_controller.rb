class API::V2::StreamController < ApplicationController
  # noinspection RailsParamDefResolve
  skip_before_action :verify_authenticity_token

  PAGE_LENGTH = 20
  before_filter :login_required,  :only => [:create, :destroy, :update, :like, :unlike]
  before_filter :fetch_post, :except => [:index, :create, :view_mention, :view_hash_tag]

  def login_required
    head :unauthorized unless logged_in? || valid_key?(params[:key])
  end

  def fetch_post
    begin
      @post = StreamPost.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      render status:404, json:{status:'Not found', id:params[:id], error: "Post by id #{params[:id]} is not found."}
    end
  end

  def index
    posts = nil
    if want_newest_posts?
      posts = newest_posts
    elsif want_older_posts?
      posts = older_posts
    elsif want_newer_posts?
      posts = newer_posts
    end
    render_json posts
  end

  def show
    limit = (params[:limit] || PAGE_LENGTH).to_i
    start_loc = (params[:page] || 0).to_i
    show_options = request_options
    show_options[:remove] = [:parent_chain]
    children = StreamPost.where(parent_chain: params[:id]).limit(limit).skip(start_loc*limit).order_by(timestamp: :asc).map { |x| x.decorate.to_hash(current_username, show_options) }
    post_result = @post.decorate.to_hash(current_username, request_options)
    if children and children.length > 0
      post_result[:children] = children
    end
    render_json post_result
  end

  def view_mention
    params[:page] = 0 unless params[:page]
    params[:page] = params[:page].to_i
    params[:limit] = PAGE_LENGTH unless params[:limit]
    params[:limit] = params[:limit].to_i
    if params[:after]
      params[:after] = Time.at(params[:after].to_f / 1000)
    end
    start_loc = params[:page]
    limit = params[:limit]
    query = StreamPost.view_mentions params
    render status: :ok, json: {status: 'ok', posts: query.map { |x| x.decorate.to_hash(current_username, request_options) }, next:(start_loc+limit)}
  end

  def view_hash_tag
    query_string = params[:query].downcase

    params[:page] = 0 unless params[:page]
    params[:page] = params[:page].to_i
    params[:limit] = PAGE_LENGTH unless params[:limit]
    params[:limit] = params[:limit].to_i

    start_loc = params[:page]
    limit = params[:limit]
    query = StreamPost.where(hash_tags: query_string).order_by(timestamp: :desc).skip(start_loc*limit).limit(limit)
    render status: :ok, json: {status: 'ok', posts: query.map { |x| x.decorate.to_hash(current_username, request_options) }, next:(start_loc+limit)}
  end

  def destroy
    unless @post.author == current_username or is_admin?
      err = [{error:"You can not delete other users' posts"}]
      return respond_to do |format|
        format.json { render json: err, status: :forbidden }
        format.xml { render xml: err, status: :forbidden }
      end
    end
    respond_to do |format|
      if @post.destroy
        format.json { head :no_content, status: :ok }
        format.xml { head :no_content, status: :ok }
      else
        format.json { render json: @post.errors, status: :unprocessable_entity }
        format.xml { render xml: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    parent_chain = []
    if params[:parent]
      parent = StreamPost.where(id: params[:parent]).first
      unless parent
        render status: :unprocessable_entity, json:{errors: ["Parent id: #{params[:parent]} was not found"]}
        return
      end
      parent_chain = parent.parent_chain + [params[:parent]]
    end
    post = StreamPost.create(text: params[:text], author: current_username, timestamp: Time.now, photo: params[:photo],
                             location: params[:location], parent_chain: parent_chain)
    if post.valid?
      if params[:location]
        # if the location field was used, update the user's last known location
        current_user.current_location = params[:location]
        current_user.save
      end
      render_json stream_post: post.decorate.to_hash(current_username, request_options)
    else
      render status: :unprocessable_entity, json:{errors: post.errors.full_messages}
    end
  end

  # noinspection RubyResolve
  def update
    unless params.has_key?(:text) or params.has_key?(:photo)
      render json:[{error:'Update may only modify text or photo.'}], status: :bad_request
      return
    end

    unless @post.author == current_username or is_admin?
      err = [{error:"You can not modify other users' posts"}]
      render json: err, status: :forbidden
      return
    end
    @post.text = params[:text] if params.has_key? :text

    if params.has_key? :photo
      unless PhotoMetadata.where(id: params[:photo]).exists?
        render json:[{error:"Unable to find photo by id #{params[:photo]}"}], status: :not_acceptable
        return
      end
      @post.photo = params[:photo]
    end

    @post.save
    if @post.valid?
      render_json stream_post: @post.decorate.to_hash(current_username, request_options)
    else
      render_json errors: @post.errors.full_messages
    end
  end

  def like
    @post = @post.add_like current_username
    render status: :ok, json: {status: 'ok', likes: @post.likes }
  end

  def show_likes
    render status: :ok, json: {status: 'ok', likes: @post.likes }
  end

  def unlike
    @post = @post.remove_like current_username
    render status: :ok, json: {status: 'ok', likes: @post.likes }
  end

  ## The following functions are helpers for the finding of new posts in the stream

  def want_newest_posts?
    not params.has_key?(:start)
  end

  def newest_posts
    start = (DateTime.now.to_f * 1000).to_i
    params[:start] = start
    older_posts.merge!({next_page: start+1})
  end

  def want_older_posts?
    params.has_key?(:start) and params.has_key?(:older_posts)
  end

  def older_posts
    start_loc = params[:start]
    author = params[:author] || nil
    limit = params[:limit] || PAGE_LENGTH
    posts = StreamPost.at_or_before(start_loc, {filter_author: author}).limit(limit).order_by(timestamp: :desc).map { |x| x }
    next_page = posts.last.nil? ? 0 : (posts.last.timestamp.to_f * 1000).to_i - 1
    {stream_posts: posts.map{|x| x.decorate.to_hash(current_username, request_options)}, next_page: next_page}
  end

  def want_newer_posts?
    params.has_key?(:start) and not params.has_key?(:older_posts)
  end

  def newer_posts
    start_loc = params[:start]
    author = params[:author] || nil
    limit = params[:limit] || PAGE_LENGTH
    posts = StreamPost.at_or_after(start_loc, {filter_author: author}).limit(limit).order_by(timestamp: :asc).map { |x| x }
    next_page = posts.last.nil? ? 0 : (posts.first.timestamp.to_f * 1000).to_i + 1
    {stream_posts: posts.map{|x| x.decorate.to_hash(current_username, request_options)}, next_page: next_page}
  end
end
