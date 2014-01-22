class PhotoMetadata < BaseModel

  attr :uploader, :original_filename, :timestamp, :store_filename, :post_id

  def self.create(uploader, original_filename, store_filename)
    new(
        uploader: uploader,
        original_filename: original_filename,
        store_filename: store_filename,
        timestamp: Time.now.to_f
    )
  end

  def timestamp_readable
    return Time.at(@timestamp) unless @timestamp.nil?
    @timestamp
  end

end