class API::V2::PhotosController < BaseRedisController

  PAGE_LENGTH = 20

  def list
    friendly_field_mapping = {'display_name' => 'original_filename',
                              'photo' => 'store_filename',
                              'time' => 'timestamp',
                              'username' => 'uploader'}

    sort_by = friendly_field_mapping[params[:sortBy]] || params[:sortBy]
    page = params[:page].to_i
    list = if sort_by.nil?
             redis.photo_list[page * PAGE_LENGTH, PAGE_LENGTH]
           else
             render_json(status: "Invalid field to sort by '#{sort_by}'") and return unless PhotoMetadata.attr.include? sort_by
             sort_options = {:limit => [page * PAGE_LENGTH, PAGE_LENGTH]}
             if sort_by != "timestamp"
               sort_options[:order] = "ALPHA"
             else
               sort_options[:order] = "ASC"
             end
             puts sort_options
             redis.photo_metadata_index.sort_list(redis.photo_list, sort_by, sort_options)
           end
    photos = redis.photo_metadata_store.get(list).reject { |x| x.post_id.nil? }
    render_json(status: 'no more items') and return if photos.blank?
    posts = redis.post_store.get(photos.map { |x| x.post_id }).reduce({}) do |hash, post|
      hash[post.post_id] = post
      hash
    end
    data = photos.map do |photo|
      post = posts[photo.post_id]
      {
          display_name: photo.original_filename,
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
