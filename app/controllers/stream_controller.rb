class StreamController < ApplicationController
  PAGE_SIZE = 20

  def page
    page_time = if params.has_key? :page
                  Time.at(params[:page].to_i / 1000.0)
                else
                  Time.now
                end
    posts = StreamPost.where(:timestamp.lt => page_time).desc(:timestamp).limit(PAGE_SIZE)
    has_next_page = posts.count > PAGE_SIZE
    posts = posts.map { |x| x }
    next_page = if posts.count > 0
                  posts.last.timestamp.to_i * 1000
                else
                  0
                end
    render_json stream_posts: posts.map { |x| x.decorate.to_twitarr_hash(current_username) }, has_next_page: has_next_page, next_page: next_page
  end


  def star_filtered_page
    return unless logged_in!
    page_time = if params.has_key? :page
                  Time.at(params[:page].to_i / 1000.0)
                else
                  Time.now
                end

    users = current_user.starred_users.reject { |x| x == current_username }
    posts = StreamPost.where(:timestamp.lt => page_time).where(:author.in => users).desc(:timestamp).limit(PAGE_SIZE)
    has_next_page = posts.count > PAGE_SIZE
    posts = posts.map { |x| x }
    next_page = if posts.count > 0
                  posts.last.timestamp.to_i * 1000
                else
                  0
                end
    render_json stream_posts: posts.map { |x| x.decorate.to_twitarr_hash(current_username) }, has_next_page: has_next_page, next_page: next_page
  end

  def create
    return unless logged_in!
    parent_chain = []
    if params[:parent]
      parent = StreamPost.where(id: params[:parent]).first
      unless parent
        render json: {errors: ["Parent id: #{params[:parent]} was not found"]}, status: :not_acceptable
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

  def get
    post = StreamPost.find(params[:id])
    render_json status: 'ok', post: post.decorate.to_base_hash
  end

  def edit
    return unless logged_in!
    post = StreamPost.find(params[:id])
    if !is_admin? && post.author != current_username
      render_json status: 'You cannot edit a post that does not belong to you.'
      return
    end
    post.edits = [] if post.edits.nil?
    post.edits << {user: current_username, old_text: post.text}
    post.text = params[:text]
    post.photo = params[:photo]
    post.save
    if post.valid?
      render_json stream_post: post.decorate.to_hash
    else
      render_json errors: post.errors.full_messages
    end
  end

  def destroy
    return unless logged_in!
    post = StreamPost.find(params[:id])
    if !is_admin? && post.author != current_username
      render_json status: 'You cannot delete a post that does not belong to you' and return
    end
    children = StreamPost.any_in(parent_chain: [params[:id]])
    children.each do |p|
      p.destroy_parent_chain
    end
    post.destroy
    render_json status: 'ok'
  end

end
