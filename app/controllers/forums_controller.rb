class ForumsController < ApplicationController

  before_filter :require_allow_modification!, only: [:create, :new_post, :update]

  def index
    return if !logged_in? and read_only_mode!
    if logged_in?
      render_json forum_meta: Forum.all.sort_by { |x| x.last_post }.reverse.map { |x| x.decorate.to_meta_hash(current_user) }
    else
      render_json forum_meta: Forum.all.sort_by { |x| x.last_post }.reverse.map { |x| x.decorate.to_meta_hash }
    end
  end

  def show
    return if !logged_in? and read_only_mode!
    if logged_in?
      render_json forum: Forum.find(params[:id]).decorate.to_hash(current_user)
      current_user.update_forum_view(params[:id]) if logged_in?
    else
      render_json forum: Forum.find(params[:id]).decorate.to_hash
    end
  end

  def create
    return if read_only_mode!
    forum = Forum.create_new_forum current_username, params[:subject], params[:text], params[:photos]
    if forum.valid?
      render_json forum_meta: forum.decorate.to_meta_hash
    else
      render_json errors: forum.errors.full_messages
    end
  end

  def new_post
    return if read_only_mode!
    forum = Forum.find(params[:forum_id])
    post = forum.add_post current_username, params[:text], params[:photos]
    if post.valid?
      render_json forum_post: post.decorate.to_hash
    else
      render_json errors: post.errors.full_messages
    end
  end

  def update
    return if read_only_mode!
    forum = Forum.find(params[:forum_id])
    forum_post = forum.posts.find(params[:forum_post_id])

    post_params = request.POST

    unless is_admin? || current_username == forum_post.author
      render_json errors: ["forum_id (#{params[:forum_id]}:#{params[:forum_post_id]}) is not owned by the user."]
      return
    end

    unless forum.id.to_str == params[:forum_id]
      render_json errors: ["forum_id (#{params[:forum_id]}) does not match the forum for post (#{params[:forum_post_id]})"]
      return
    end

    puts post_params.keys - %w(subject text photos forum)
    unless (post_params.keys - %w(subject text photos forum)).empty?
      render json: [{ error: 'Unable to modify fields other than subject, text or photos' }], status: :bad_request
      return
    end

    if post_params.has_key? :subject
      unless forum.posts.first.id.to_str == params[:forum_post_id]
        render_json errors: ['You can only modify the subject of the forum, while editing the first post']
        return
      end
      forum.subject = post_params[:subject]
      forum_post[:subject] = post_params[:subject]
    end

    if post_params.has_key? :text
      forum_post[:text] = post_params[:text]
    end

    if post_params.has_key? :photos
      forum_post[:photos] = post_params[:photos]
    end
    if forum.valid?
      forum.save!
      render_json forum_post: forum.decorate.to_hash
    else
      render_json errors: forum.errors.full_messages
    end
  end

end
