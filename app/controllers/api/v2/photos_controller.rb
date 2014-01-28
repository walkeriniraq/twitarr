class API::V2::PhotosController < BaseRedisController

  PAGE_LENGTH = 20

  def list
    page = params[:page].to_i
    list = redis.photo_list[page * PAGE_LENGTH, PAGE_LENGTH]
    photos = redis.photo_metadata_store.get(list)
    render_json(status: 'no more items') and return if photos.blank?
    data = photos.map { |x| { photo: x.store_filename } }
    redis.post_store.get(photos.map { |x| x.post_id }).each_with_index do |post, idx|
      data[idx][:time] = post.post_time
      data[idx][:username] = post.username
      data[idx][:message] = post.message
    end
    render_json status: 'ok',
                total_count: redis.photo_list.size,
                page: page,
                items: data.size,
                photos: data
  end

end
