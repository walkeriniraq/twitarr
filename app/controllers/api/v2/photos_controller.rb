class API::V2::PhotosController < BaseRedisController

  PAGE_LENGTH = 20

  def list
    page = params[:page].to_i
    list = redis.photo_list[page * PAGE_LENGTH, PAGE_LENGTH]
    photos = redis.photo_metadata_store.get(list).reject { |x| x.post_id.nil? }
    render_json(status: 'no more items') and return if photos.blank?
    posts = redis.post_store.get(photos.map { |x| x.post_id }).reduce({}) do |hash, post|
      hash[post.post_id] = post
      hash
    end
    data = photos.map do |photo|
      post = posts[photo.post_id]
      {
          photo: photo.store_filename,
          time: post.andand.post_time,
          username: post.andand.username,
          message: post.andand.message
      }
    end
    render_json status: 'ok',
                total_count: redis.photo_list.size,
                page: page,
                items: data.size,
                photos: data
  end

end
