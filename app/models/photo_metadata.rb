class PhotoMetadata
  include Mongoid::Document

  field :up, as: :uploader, type: String
  field :ofn, as: :original_filename, type: String
  field :fn, as: :store_filename, type: String
  field :ut, as: :upload_time, type: Time
  field :hsh, as: :md5_hash, type: String

end