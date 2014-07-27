require 'RMagick'

class PostsController < ApplicationController

  def page
    render_json stream_posts: [{
                                   id: 1,
                                   author: 'dave',
                                   text: 'something something something',
                                   timestamp: DateTime.now
                               }, {
                                   id: 2,
                                   author: 'walter',
                                   text: 'more more more',
                                   timestamp: DateTime.now
                               }]
  end

  def create
    response = { id: 123, text: params[:text], author: current_username, timestamp: DateTime.now }
    render_json stream_post: response
  end

  # def submit
  #   return read_only_mode if Twitarr::Application.config.read_only
  #   return login_required unless logged_in?
  #   return render_json status: 'Photo upload is limited to five per post' if params[:photos] && params[:photos].count > 5
  #   TwitarrDb.create_post current_username, params[:message], params[:photos]
  #   render_json status: 'ok'
  # end
  #
  # def delete
  #   return read_only_mode if Twitarr::Application.config.read_only
  #   return login_required unless logged_in?
  #   post = redis.post_store.get(params[:id])
  #   return render_json status: 'Posts can only be deleted by their owners.' unless post.username == current_username || is_admin?
  #   context = DeletePostContext.new post: post,
  #                                   tag_factory: tag_factory(redis),
  #                                   popular_index: redis.popular_posts_index,
  #                                   post_index: redis.post_index,
  #                                   post_store: redis.post_store
  #   context.call
  #   render_json status: 'ok'
  # end
  #
  # def reply
  #   return read_only_mode if Twitarr::Application.config.read_only
  #   return login_required unless logged_in?
  #   reply = TwitarrDb.add_post_reply current_username, params[:message], params[:id]
  #   render_json status: 'ok', reply: reply
  # end

  # def upload
  #   return read_only_mode if Twitarr::Application.config.read_only
  #   return render_json status: 'Must provide photos to upload.' if params[:files].blank?
  #   files = params[:files].map { |file| process_upload file, redis }
  #   if browser.ie?
  #     render text: { status: 'ok', files: files }.to_json
  #   else
  #     render_json status: 'ok', files: files
  #   end
  # end
  #
  # TEN_MB = 10 * 1024 * 1024
  #
  # def process_upload(file, redis)
  #   ext = Pathname.new(file.original_filename).extname.downcase
  #   return { status: 'file is over 10MB', filename: file.original_filename } unless file.size <= TEN_MB
  #   return { status: 'file was not an allowed image type', filename: file.original_filename } unless %w(.jpg .jpeg .png .gif).include? ext
  #   new_filename = SecureRandom.uuid.to_s + ext
  #   FileUtils.copy(file.tempfile, 'public/img/photos/' + new_filename)
  #   Pathname.new('public/img/photos/' + new_filename).chmod(0664)
  #   begin
  #     img = Magick::Image::read('public/img/photos/' + new_filename).first
  #   rescue Java::JavaLang::NullPointerException
  #     # yeah, ImageMagick throws a NPE if the photo isn't a photo
  #     return { status: 'file was not an image file or corrupt', filename: file.original_filename }
  #   end
  #   if ext == '.jpg' || ext == '.jpeg'
  #     orientation = EXIFR::JPEG.new('public/img/photos/' + new_filename).orientation
  #     if orientation
  #       img = orientation.transform_rmagick(img)
  #       img.write('public/img/photos/' + new_filename)
  #     end
  #   end
  #   img.resize_to_fit(150, 150).write('public/img/photos/sm_' + new_filename)
  #   img.resize_to_fit(500, 500).write('public/img/photos/md_' + new_filename)
  #   metadata = PhotoMetadata.create current_username, file.original_filename, new_filename
  #   redis.photo_metadata_store.save metadata, new_filename
  #   redis.photo_metadata_index.index metadata, new_filename
  #   { status: 'ok', filename: new_filename }
  # rescue EXIFR::MalformedJPEG
  #   return { status: 'file extension is jpg but was not a jpeg', filename: file.original_filename }
  # end
  #
  # def delete_upload
  #   begin
  #     location = Rails.root + '/public/img/photos/' # The address ember photos return is something along the lines of "img/photos/[hash].jpg"
  #
  #     file = CGI.escape(params[:file].to_s) # Without to_s, CGI.Escape fails.
  #     medium = "md_" + file
  #     thumb = "sm_" + file
  #     File.delete(location + file) if File.exist?(location + file)
  #     File.delete(location + medium) if File.exist?(location + medium)
  #     File.delete(location + thumb) if File.exist?(location + thumb)
  #     redis.photo_metadata_store.delete(file)
  #     render_json status: 'success'
  #   rescue Exception => e # Needs to be fixed to be more specific. I feel bad doing a root exception.
  #     render_json status: :internal_server_error, error: e.to_s
  #   end
  # end
  #
  # def favorite
  #   return read_only_mode if Twitarr::Application.config.read_only
  #   return login_required unless logged_in?
  #   post = redis.post_store.get params[:id]
  #   context = LikePostContext.new post: post,
  #                                 post_likes: redis.post_favorites_set(post.post_id),
  #                                 username: current_username,
  #                                 popular_index: redis.popular_posts_index
  #   context.call
  #   favorites = UserFavorites.new(redis, current_username, [post.post_id])
  #   render_json status: 'ok', sentence: post.decorate.liked_sentence(favorites)
  # end
  #
  # def popular
  #   posts = redis.popular_posts_index.revrange 0, EntryListContext::PAGE_SIZE
  #   context = EntryListContext.new posts_index: posts,
  #                                  post_store: redis.post_store
  #   render_json status: 'ok', more: false, list: list_output(context.call)
  # end
  #
  # def tag_cloud
  #   tags = redis.tag_scores.revrangebyscore('+inf', 2, count: 10, with_scores: true).map { |x, y| { tag: x, count: y } }
  #   render_json status: 'ok', tags: tags.shuffle
  # end
  #
  # def all
  #   posts, announcements, more = filter_direction_both redis.post_index, redis.announcements, params[:dir], params[:time]
  #   context = EntryListContext.new announcement_list: announcements,
  #                                  posts_index: posts,
  #                                  post_store: redis.post_store
  #   render_json status: 'ok', more: more, list: list_output(context.call)
  # end
  #
  # def list
  #   return render_json(status: 'missing username') unless params[:username]
  #   user = redis.user_store.get(params[:username].downcase)
  #   return render_json(status: 'Could not find user!') if user.nil?
  #   posts, more = filter_direction_posts redis.tag_index("@#{user.username}"), params[:dir], params[:time]
  #   context = EntryListContext.new posts_index: posts,
  #                                  post_store: redis.post_store
  #   if user.username == current_username
  #     user.update_last_checked_posts
  #     redis.user_store.save user, user.username
  #   end
  #   render_json status: 'ok', more: more, list: list_output(context.call)
  # end
  #
  # def search
  #   posts, more = filter_direction_posts redis.tag_index("##{params[:term]}"), params[:dir], params[:time]
  #   context = EntryListContext.new posts_index: posts,
  #                                  post_store: redis.post_store
  #   render_json status: 'ok', more: more, list: list_output(context.call)
  # end
  #
  # def list_output(list)
  #   ids = list.reduce([]) { |list, x| list << x.entry_id if x.type == :post; list }
  #   favorites = UserFavorites.new(redis, current_username, ids)
  #   list.map { |x| x.decorate.gui_hash_with_favorites(favorites) }
  # end
  #
  # def filter_direction_posts(posts, direction, time)
  #   posts = case
  #             when direction == 'before'
  #               posts.revrangebyscore(
  #                   time.to_f - 0.000001,
  #                   0,
  #                   limit: EntryListContext::PAGE_SIZE + 1
  #               )
  #             when direction == 'after'
  #               posts.rangebyscore(
  #                   time.to_f + 0.000001,
  #                   Time.now.to_f,
  #                   limit: EntryListContext::PAGE_SIZE + 1
  #               )
  #             else
  #               posts.revrange 0, EntryListContext::PAGE_SIZE + 1
  #           end
  #   more = posts.count > EntryListContext::PAGE_SIZE
  #   posts = posts.first(EntryListContext::PAGE_SIZE) if more
  #   return posts, more
  # end
  #
  # def filter_direction_both(posts, announcements, direction, time)
  #   case
  #     when direction == 'before'
  #       from = time.to_f - 0.000001
  #       to = 0
  #       posts = posts.revrangebyscore(from, to, limit: EntryListContext::PAGE_SIZE + 1)
  #     when direction == 'after'
  #       from = time.to_f + 0.000001
  #       to = (Time.now + 7.days).to_f
  #       posts = posts.rangebyscore(from, to, limit: EntryListContext::PAGE_SIZE + 1)
  #     else
  #       from = (Time.now + 7.days).to_f
  #       to = 0
  #       posts = posts.revrange(0, EntryListContext::PAGE_SIZE + 1)
  #   end
  #   announcements = get_announcements(announcements, from, to)
  #   more = posts.count > EntryListContext::PAGE_SIZE || announcements.count > EntryListContext::PAGE_SIZE
  #   if more
  #     posts = posts.first(EntryListContext::PAGE_SIZE)
  #     announcements = announcements.first(EntryListContext::PAGE_SIZE)
  #   end
  #   return posts, announcements, more
  # end
  #
  # # this ugliness is because announcements are indexed with the time_offset included
  # def get_announcements(index, from, to)
  #   if from < to
  #     index.get(from, to, EntryListContext::PAGE_SIZE).select { |x| x.post_time > from && x.post_time < to }
  #   else
  #     index.get(from, to, EntryListContext::PAGE_SIZE).select { |x| x.post_time < from && x.post_time > to }
  #   end
  # end
  #
  # def tag_autocomplete
  #   render_json status: 'ok', names: redis.tag_auto.query(params[:string])
  # end

end