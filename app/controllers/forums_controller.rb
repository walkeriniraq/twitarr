class ForumsController < ApplicationController

  def page
    per_page = 20
    offset = params[:page].to_i || 0

    threads = Forum.offset(offset * per_page).limit(per_page).sort_by(&:last_post).reverse
    if logged_in?
      threads = threads.map { |x| x.decorate.to_meta_hash(current_user) }
    else
      threads = threads.map { |x| x.decorate.to_meta_hash }
    end
    next_page = offset + 1
    next_page = nil if Forum.offset((offset + 1) * per_page).limit(per_page).to_a.count ==  0
    prev_page = offset - 1
    prev_page = nil if prev_page < 0
    render_json forum_meta: threads, next_page: next_page, prev_page: prev_page
  end

  def index
    if logged_in?
      render_json forum_meta: Forum.all.sort_by(&:last_post).reverse.map { |x| x.decorate.to_meta_hash(current_user) }
    else
      render_json forum_meta: Forum.all.sort_by(&:last_post).reverse.map { |x| x.decorate.to_meta_hash }
    end
  end

  def show
    page = params[:page].to_i || 0
    if logged_in?
      render_json forum: Forum.find(params[:id]).decorate.to_paginated_hash(page,current_user)
      current_user.update_forum_view(params[:id]) if logged_in?
    else
      render_json forum: Forum.find(params[:id]).decorate.to_paginated_hash(page)
    end
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
    forum = Forum.find(params[:forum_id])
    post = forum.add_post current_username, params[:text], params[:photos]
    if post.valid?
      render_json forum_post: post.decorate.to_hash(nil, nil, request_options)
    else
      render_json errors: post.errors.full_messages
    end
  end

  def delete_post
    forum = Forum.find(params[:forum_id])
    forum_post = forum.posts.find(params[:forum_post_id])

    unless is_admin? || current_username == forum_post.author
      render_json errors: ["forum_id (#{params[:forum_id]}:#{params[:forum_post_id]}) is not owned by the user."]
      return
    end

    unless forum.id.to_str == params[:forum_id]
      render_json errors: ["forum_id (#{params[:forum_id]}) does not match the forum for post (#{params[:forum_post_id]})"]
      return
    end

    if forum_post.valid?
      forum_post.destroy!
      forum.destroy! if forum.posts.count <= 1 # If the post is *only* the OP, delete the forum, else everything breaks
      render_json status: 'OK'
    end
  end

  def update
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
      render_json forum_post: forum.decorate.to_hash(nil, nil, request_options)
    else
      render_json errors: forum.errors.full_messages
    end
  end

end
