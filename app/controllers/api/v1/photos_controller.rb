class API::V1::PhotosController < BaseRedisController

  PAGE_LENGTH = 20

  def list
    page = params[:page].to_i
    photos = redis.photo_metadata_store.all.
        reject { |x| x.post_id.nil? }
    photo_count = photos.size
    photos = photos[page * PAGE_LENGTH, PAGE_LENGTH]
    render_json(status: 'no more items') and return if photos.blank?
    data = photos.map { |x| { photo: x.store_filename } }
    redis.post_store.get(photos.map { |x| x.post_id }).each_with_index do |post, idx|
      data[idx][:message] = post.message
    end
    render_json status: 'ok',
                total_count: photo_count,
                page: page,
                items: data.size,
                photos: data
  end

end