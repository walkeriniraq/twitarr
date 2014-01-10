require 'rmagick'

class PostsController < ApplicationController

  def submit
    return login_required unless logged_in?
    TwitarrDb.create_post current_username, params[:message], params[:photos]
    render_json status: 'ok'
  end

  def delete
    return login_required unless logged_in?
    post = redis.post_store.get(params[:id])
    return render_json status: 'Posts can only be deleted by their owners.' unless post.username == current_username || is_admin?
    context = DeletePostContext.new post: post,
                                    tag_factory: tag_factory(redis),
                                    popular_index: redis.popular_posts_index,
                                    post_index: redis.post_index,
                                    post_store: redis.post_store
    context.call
    render_json status: 'ok'
  end

  def reply
    return login_required unless logged_in?
    reply = TwitarrDb.add_post_reply current_username, params[:message], params[:id]
    render_json status: 'ok', reply: reply
  end

  def upload
    saved_files = []
    params[:files].each do |file|
      file_hash = Digest::MD5.hexdigest(File.read(file.tempfile))
      if redis.file_hash_map.include? file_hash
        new_filename = redis.file_hash_map[file_hash]
      else
        ext = Pathname.new(file.original_filename).extname
        new_filename = SecureRandom.uuid.to_s + ext
        FileUtils.copy(file.tempfile, 'public/img/photos/' + new_filename)
        Pathname.new('public/img/photos/' + new_filename).chmod(0664)
        img = Magick::Image::read('public/img/photos/' + new_filename).first
        if ext == '.jpg'
          puts 'ROTATING'
          img = EXIFR::JPEG.new('public/img/photos/' + new_filename).orientation.transform_rmagick(img)
        end
        # also png
        img.write('public/img/photos/' + new_filename)
        img.resize_to_fit(150, 150).write('public/img/photos/sm_' + new_filename)
        img.resize_to_fit(600, 600).write('public/img/photos/md_' + new_filename)
        #ImageVoodoo.with_image file.path do |img|
        #  img.thumbnail 150 do |thumb|
        #    thumb.save 'public/img/photos/sm_' + new_filename
        #  end
        #  img.thumbnail 600 do |thumb|
        #    thumb.save 'public/img/photos/md_' + new_filename
        #  end
        #end
        redis.file_hash_map[file_hash] = new_filename
      end
      saved_files << new_filename
      #puts file.original_filename
    end
    render_json status: 'ok', saved_files: saved_files
  end

  def favorite
    return login_required unless logged_in?
    post = redis.post_store.get params[:id]
    context = LikePostContext.new post: post,
                                  post_likes: redis.post_favorites_set(post.post_id),
                                  username: current_username,
                                  popular_index: redis.popular_posts_index,
                                  user_feed: redis.feed_index(current_username)
    context.call
    favorites = UserFavorites.new(redis, current_username, [post.post_id])
    render_json status: 'ok', sentence: post.decorate.liked_sentence(favorites)
  end

  def popular
    posts = redis.popular_posts_index.revrange 0, EntryListContext::PAGE_SIZE
    context = EntryListContext.new posts_index: posts,
                                   post_store: redis.post_store
    render_json status: 'ok', more: false, list: list_output(context.call)
  end

  def all
    posts, announcements, more = filter_direction_both redis.post_index, redis.announcements, params[:dir], params[:time]
    context = EntryListContext.new announcement_list: announcements,
                                   posts_index: posts,
                                   post_store: redis.post_store
    render_json status: 'ok', more: more, list: list_output(context.call)
  end

  def list
    return render_json(status: 'missing username') unless params[:username]
    user = redis.user_store.get(params[:username])
    return render_json(status: 'Could not find user!') if user.nil?
    posts, more = filter_direction_posts redis.tag_index("@#{user.username}"), params[:dir], params[:time]
    context = EntryListContext.new posts_index: posts,
                                   post_store: redis.post_store
    if user.username == current_username
      user.update_last_checked_posts
      redis.user_store.save user, user.username
    end
    render_json status: 'ok', more: more, list: list_output(context.call)
  end

  def search
    posts, more = filter_direction_posts redis.tag_index("##{params[:term]}"), params[:dir], params[:time]
    context = EntryListContext.new posts_index: posts,
                                   post_store: redis.post_store
    render_json status: 'ok', more: more, list: list_output(context.call)
  end

  def list_output(list)
    ids = list.reduce([]) { |list, x| list << x.entry_id if x.type == :post; list }
    favorites = UserFavorites.new(redis, current_username, ids)
    list.map { |x| x.decorate.gui_hash_with_favorites(favorites) }
  end

  def filter_direction_posts(posts, direction, time)
    posts = case
              when direction == 'before'
                posts.revrangebyscore(
                    time.to_f - 0.000001,
                    0,
                    limit: EntryListContext::PAGE_SIZE + 1
                )
              when direction == 'after'
                posts.rangebyscore(
                    time.to_f + 0.000001,
                    Time.now.to_f,
                    limit: EntryListContext::PAGE_SIZE + 1
                )
              else
                posts.revrange 0, EntryListContext::PAGE_SIZE + 1
            end
    more = posts.count > EntryListContext::PAGE_SIZE
    posts = posts.first(EntryListContext::PAGE_SIZE) if more
    return posts, more
  end

  def filter_direction_both(posts, announcements, direction, time)
    case
      when direction == 'before'
        from = time.to_f - 0.000001
        to = 0
        posts = posts.revrangebyscore(from, to, limit: EntryListContext::PAGE_SIZE + 1)
      when direction == 'after'
        from = time.to_f + 0.000001
        to = (Time.now + 7.days).to_f
        posts = posts.rangebyscore(from, to, limit: EntryListContext::PAGE_SIZE + 1)
      else
        from = (Time.now + 7.days).to_f
        to = 0
        posts = posts.revrange(0, EntryListContext::PAGE_SIZE + 1)
    end
    announcements = get_announcements(announcements, from, to)
    more = posts.count > EntryListContext::PAGE_SIZE || announcements.count > EntryListContext::PAGE_SIZE
    if more
      posts = posts.first(EntryListContext::PAGE_SIZE)
      announcements = announcements.first(EntryListContext::PAGE_SIZE)
    end
    return posts, announcements, more
  end

  # this ugliness is because announcements are indexed with the time_offset included
  def get_announcements(index, from, to)
    if from < to
      index.get(from - 5.days, to + 5.days, EntryListContext::PAGE_SIZE).select { |x| x.post_time > from && x.post_time < to }
    else
      index.get(from + 5.days, to - 5.days, EntryListContext::PAGE_SIZE).select { |x| x.post_time < from && x.post_time > to }
    end
  end

  def tag_autocomplete
    render_json status: 'ok', names: redis.tag_auto.query(params[:string])
  end

end